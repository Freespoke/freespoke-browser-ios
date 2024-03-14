// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import StoreKit

typealias RestorePurchasesCompletionHandler = (_ status: InAppManagerServiceRestorationStatus) -> Void

enum InAppManagerServiceRestorationStatus {
    case canNotMakePayments
    case noTransactionsToRestore
    case restorePurchasesRequestFailed
    case restored
    case failed
    
    var userMessage: String {
        switch self {
        case .canNotMakePayments:
            return "Subscriptions are not available on current device"
        case .noTransactionsToRestore:
            return "There are no items available to restore at this time"
        case .restorePurchasesRequestFailed, .failed:
            return "Restore Subscription Failed"
        case .restored:
            return "Your Subscription restored Successfully"
        }
    }
}

enum StoreKitError: Error {
    case failedVerification
    case unknownError
}

enum PurchaseStatus {
    case success(String)
    case pending
    case cancelled
    case failed(Error)
    case unknown
}

struct ProductIdentifiers {
    static var monthlySubscription: String {
        switch FreespokeEnvironment.current {
        case .production:
            "premium_monthly"
        case .staging:
            "premium_monthly"  // TODO: remove before upload staging build
//            "MonthlyRenewableSubscription_staging"   // TODO: uncommit before upload staging build
        }
    }
    
    static var yearlySubscription: String {
        switch FreespokeEnvironment.current {
        case .production:
            "premium_annual"
        case .staging:
            "premium_annual"  // TODO: remove before upload staging build
//            "YearlyRenewableSubscription_staging"   // TODO: uncommit before upload staging build
        }
    }
}

protocol InAppManagerServiceProtocol {
    func restorePurchases(completionHandler: @escaping RestorePurchasesCompletionHandler)
}

class InAppManager: NSObject, InAppManagerServiceProtocol {
    public static var shared = InAppManager()
    private var products = [Product]()
    var transactionCompletionStatus: Bool = false
    
    private let productIds = [ProductIdentifiers.monthlySubscription,
                              ProductIdentifiers.yearlySubscription]
    private(set) var purchaseStatus: PurchaseStatus = .unknown
    private var transactionListener: Task<Void, Error>?
    
    private var restorePurchasesCompletionHandler: RestorePurchasesCompletionHandler?
    private let paymentQueue = SKPaymentQueue.default()
    
    override init() {
        super.init()
        Task {
            await retrieveProducts()
            self.transactionListener = Task {
                await self.transactionStatusStream()
            }
            self.paymentQueue.add(self)
        }
    }
    
    deinit {
        self.transactionListener?.cancel()
        SKPaymentQueue.default().remove(self)
    }
    
    func getProductIds() -> [String] {
        return self.productIds
    }
    
    func getProduct() -> [Product] {
        return self.products
    }
    
    /// Get all of the in-app products
    func retrieveProducts() async {
        do {
            let productIdentifiers: Set<String> = [ProductIdentifiers.monthlySubscription,
                                                   ProductIdentifiers.yearlySubscription]
            let products = try await Product.products(for: productIdentifiers)
            self.products = products.sorted(by: { $0.price < $1.price })
            for product in self.products {
                print("Test INAP ------In-App Product:: \(product.displayName) in \(product.displayPrice)")
            }
        } catch {
            print(error)
        }
    }
    
    /// Purchase the in-app product
    func purchase(_ item: Product, appAccountToken: UUID) async -> Bool {
        do {
            let result = try await item.purchase(options: [Product.PurchaseOption.appAccountToken(appAccountToken)])
            
            switch result {
            case .success(let verification):
                do {
                    let verificationResult = try verifyPurchase(verification)
                    self.purchaseStatus = .success(verificationResult.productID)
                    await verificationResult.finish()
                    self.transactionCompletionStatus = true
                    return true
                } catch {
                    self.purchaseStatus = .failed(error)
                    self.transactionCompletionStatus = true
                    return false
                }
            case .pending:
                self.purchaseStatus = .pending
                self.transactionCompletionStatus = false
                return false
            case .userCancelled:
                self.purchaseStatus = .cancelled
                self.transactionCompletionStatus = false
                return false
            default:
                self.purchaseStatus = .failed(StoreKitError.unknownError)
                self.transactionCompletionStatus = false
                return false
            }
        } catch {
            self.purchaseStatus = .failed(error)
            self.transactionCompletionStatus = false
            return false
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func refreshPurchasedProducts() async {
        // Iterate through the user's purchased products.
        for await verificationResult in Transaction.currentEntitlements {
            switch verificationResult {
            case .verified(let transaction):
                // Check the type of product for the transaction
                // and provide access to the content as appropriate.
                switch transaction.productID {
                case ProductIdentifiers.monthlySubscription:
                    print("Monthly subscription purchased!")
                case ProductIdentifiers.yearlySubscription:
                    print("Yearly subscription purchased!")
                default:
                    // Handle other product IDs if needed
                    print("Unknown product purchased!")
                }
            case .unverified(let unverifiedTransaction, let verificationError):
                UIUtils.showOkAlert(title: "Unverified transaction: \(unverifiedTransaction)", message: "error: \(verificationError)")
            }
        }
    }
    
    /// Verify Purchase
    func verifyPurchase<T>(_ verificationResult: VerificationResult<T>) throws -> T {
        switch verificationResult {
        case .unverified(_, let error):
            throw error
        case .verified(let result):
            return result
        }
    }
    
    /// Handle Interruptions
    func transactionStatusStream() async {
        do {
            for await result in Transaction.updates {
                let transaction = try self.verifyPurchase(result)
                self.purchaseStatus = .success(transaction.productID)
                self.transactionCompletionStatus = true
                await transaction.finish()
            }
        } catch {
            self.transactionCompletionStatus = true
            self.purchaseStatus = .failed(error)
        }
    }
    
    // MARK: - SKPaymentTransactionObserver methods
    func restorePurchases(completionHandler: @escaping RestorePurchasesCompletionHandler) {
        self.restorePurchasesCompletionHandler = completionHandler
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            self.restorePurchasesCompletionHandler?(.canNotMakePayments)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        guard queue.transactions.isEmpty else {
            self.restorePurchasesCompletionHandler?(.noTransactionsToRestore)
            return
        }
        
        queue.transactions.forEach({ transaction in
            queue.finishTransaction(transaction)
        })
        
        self.restorePurchasesCompletionHandler?(.restored)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.restorePurchasesCompletionHandler?(.failed)
    }
}

extension InAppManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
#if DEBUG
            print("transactionState.rawValue => ", transaction.transactionState.rawValue)
            print("Transaction status: ", transaction.transactionState.status(), "\n", "product_identifier: ", transaction.payment.productIdentifier)
#endif
            switch transaction.transactionState {
            case .purchased:
                print("self.buyProductCompletionHandler?(.purchased)")
            case .failed:
                queue.finishTransaction(transaction)
            case .purchasing, .deferred, .restored:
                break
            @unknown default:
                break
            }
        }
    }
}
