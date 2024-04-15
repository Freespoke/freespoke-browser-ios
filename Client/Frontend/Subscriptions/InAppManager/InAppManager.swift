// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import StoreKit
import Combine

public enum StoreError: Error {
    case failedVerification
}

class InAppManager: NSObject, InAppManagerProtocol {
    // MARK: Properties
    static let shared = InAppManager()
    
    /// Notifies that the product prices loaded. And the spinner can be replaced with the real price where appropriate.
    var getProductsFinishedAction = PassthroughSubject<[Product], Never>()
    
    private var postTransactionSubscription: AnyCancellable?
    private var getCourseSubscription: AnyCancellable?
    private var restorePurchasesSubscription: AnyCancellable?
    
    private let productsIds = [ProductIdentifiers.monthlySubscription,
                               ProductIdentifiers.yearlySubscription]
    
    private var products: [Product] = []
    private var taskTransactionsHandle: Task<Void, Error>?
//    private var networkManager = NetworkManager()
    
    private override init() {
        super.init()
        self.taskTransactionsHandle = self.listenForTransactions()
    }
}

// MARK: - AppStore Products

extension InAppManager {
    private func requestProduct(productID: String) async throws -> Product? {
        try await Product.products(for: [productID]).first(where: { $0.id == productID })
    }
    
    private func requestProducts(productIDs: [String]) async throws -> [Product]? {
        try await Product.products(for: productIDs)
    }
    
    func requestProductsInfo() {
        Task {
            do {
                guard let products = try await self.requestProducts(productIDs: self.productsIds) else {
                    self.getProductsFinishedAction.send(self.products)
                    return
                }
                self.products = products
                self.getProductsFinishedAction.send(self.products)
            } catch {
                self.getProductsFinishedAction.send(self.products)
            }
        }
    }
    
    func product(productId: String) -> CustomProduct? {
        guard let product = products.first(where: { $0.id == productId }) else { return nil }
        return CustomProduct(productID: product.id,
                             price: product.price as NSDecimalNumber,
                             priceLocale: product.priceFormatStyle.locale,
                             displayPrice: product.displayPrice)
    }
}

// MARK: - Purchase

extension InAppManager {
    func purchaseProduct(productIdentifier: String, appAccountToken: UUID, completion: @escaping((IAPManagerPurchasingStatus) -> Void)) {
        guard SKPaymentQueue.canMakePayments() else {
            completion(.canNotMakePayments)
            return
        }
        
        Task { @MainActor in
            do {
                let isPurchasedResult = try await self.isPurchased(productIdentifier)
                guard !isPurchasedResult.isPurchased else {
                    completion(.failed(customMessage: "Subscription failed. User has already subscribed."))
                    return
                }
                
                guard let product = try await self.requestProduct(productID: productIdentifier) else {
                    completion(.storeProductNotAvailable)
                    return
                }
                
                let result = try await product.purchase(options: [Product.PurchaseOption.appAccountToken(appAccountToken)])
                
                self.processPurchaseResult(product: product,
                                           result: result,
                                           completion: completion)
            } catch {
                self.processPurchaseResultError(error: error, completion: completion)
            }
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                } catch {
                    print("TEST: listenForTransactions Transaction failed verification error: ", error)
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case let .verified(safe):
            return safe
        }
    }
    
    func appleAccountHasActiveAppSubscription() async throws -> Bool {
        if let monthlyPurchased = try? await self.isPurchased(ProductIdentifiers.monthlySubscription) {
            return true
        }
        
        if let yearlyPurchased = try? await self.isPurchased(ProductIdentifiers.yearlySubscription) {
            return true
        }
        
        return false
    }
    
    func isPurchased(_ productIdentifier: String) async throws -> (isPurchased: Bool, usingCurrentAccount: Bool?) {
        guard let result = await Transaction.latest(for: productIdentifier) else { return (false, nil) }
        let transaction = try self.checkVerified(result)
        
        var expired = false
        
        if let expirationDate = transaction.expirationDate, expirationDate < Date() {
            expired = true
        }
        
        let purchased = transaction.revocationDate == nil && !transaction.isUpgraded && !expired
        
        if purchased {
            if let appAccountToken = transaction.appAccountToken,
                appAccountToken == AppSessionManager.shared.decodedJWTToken?.externalAccountId {
                return (true, true)
            } else {
                return (true, false)
            }
        } else {
            return (false, nil)
        }
    }
    
    private func processPurchaseResult(product: Product, result: Product.PurchaseResult, completion: @escaping((IAPManagerPurchasingStatus) -> Void)) {
        Task {
            switch result {
            case let .success(verification):
                let transaction = try self.checkVerified(verification)
                await transaction.finish()
                // TODO: Call request to post transaction (originalID) to our backend
                
                
                
                completion(.subscribed(product: product))
            case .pending:
                // Family sharing is not acitvated for now in AppStore.
                completion(.failed(customMessage: "Family sharing is not acitvated for now in AppStore."))
            case .userCancelled:
                completion(.cancelled)
            @unknown default:
                completion(.failed())
            }
        }
    }
}

// MARK: - Restore Purchases

extension InAppManager {
    func restorePurchasesAtAppStart() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func restorePurchases(appAccountToken: UUID, completion: @escaping((IAPManagerRestorationStatus) -> Void)) {
        Task {
            do {
                try await AppStore.sync()
                let entitlements = Transaction.currentEntitlements
                
                var originalTransactionId: UInt64?
                
                for await entitlement in entitlements {
                    if let transaction = try? self.checkVerified(entitlement) {
//                        originalTransactionId = transaction.originalID
//                        self.networkManager.restorePurchase(signedPayload: entitlement.jwsRepresentation,
//                                                            completion: { response, error in
//                            if let response = response {
//                                completion(.restored(message: response.message))
//                            } else if let error = error {
//                                completion(.restorePurchasesFailed(customMessage: error.errorDescription))
//                            } else {
//                                completion(.restorePurchasesFailed())
//                            }
//                        })
                        break
                    }
                }
                
                guard let originalTransactionId = originalTransactionId else {
                    completion(.noTransactionsToRestore)
                    return
                }
                completion(.restored)
            } catch {
                if let error = error as? StoreKitError {
                    self.processRestorePurchasesError(error: error, completion: completion)
                } else {
                    completion(.restorePurchasesFailed())
                }
            }
        }
    }
    
    // MARK: Purchases Errors
    
    private func processRestorePurchasesError(error: StoreKitError, completion: @escaping((IAPManagerRestorationStatus) -> Void)) {
        switch error {
        case .userCancelled:
            completion(.userCancelled)
        case .systemError,
                .networkError,
                .notEntitled,
                .unknown:
            completion(.restorePurchasesFailed())
        case .notAvailableInStorefront:
            completion(.storeProductNotAvailable)
        @unknown default:
            completion(.restorePurchasesFailed())
        }
    }
}

// MARK: - Purchases Errors

extension InAppManager {
    private func processPurchaseResultError(error: Error, completion: @escaping((IAPManagerPurchasingStatus) -> Void)) {
        if let error = error as? SKError {
            self.handleError(error: error, completion: completion)
        } else if let error = error as? StoreError {
            self.handleError(error: error, completion: completion)
        } else if let error = error as? Product.PurchaseError {
            self.handleError(error: error, completion: completion)
        } else {
            completion(.failed())
        }
    }
    
    // MARK: Handle SKError
    
    private func handleError(error: SKError, completion: @escaping((IAPManagerPurchasingStatus) -> Void)) {
        switch error.code {
        case .clientInvalid, .paymentNotAllowed:
            completion(.canNotMakePayments)
        case .paymentCancelled:
            completion(.cancelled)
        case .paymentInvalid:
            completion(.failed())
        case .storeProductNotAvailable:
            completion(.storeProductNotAvailable)
        case .cloudServiceRevoked:
            completion(.failed())
        case .cloudServicePermissionDenied:
            completion(.failed())
        case .cloudServiceNetworkConnectionFailed:
            completion(.failed())
        case .privacyAcknowledgementRequired:
            completion(.failed())
        case .unauthorizedRequestData:
            completion(.failed())
        case .invalidSignature:
            completion(.failed())
        default:
            completion(.failed())
        }
    }
    
    // MARK: Handle StoreError
    
    private func handleError(error: StoreError, completion: @escaping((IAPManagerPurchasingStatus) -> Void)) {
        switch error {
        case .failedVerification:
            completion(.failed())
        }
    }
    
    // MARK: Handle Product.PurchaseError
    
    private func handleError(error: Product.PurchaseError, completion: @escaping((IAPManagerPurchasingStatus) -> Void)) {
        switch error {
        case .invalidQuantity:
            completion(.failed())
        case .productUnavailable:
            completion(.failed())
        case .purchaseNotAllowed:
            completion(.canNotMakePayments)
        case .ineligibleForOffer,
                .invalidOfferIdentifier,
                .invalidOfferPrice,
                .missingOfferParameters:
            completion(.failed())
        case .invalidOfferSignature:
            completion(.failed())
        @unknown default:
            completion(.failed())
        }
    }
}
