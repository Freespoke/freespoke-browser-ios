// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Combine
import StoreKit

struct ProductIdentifiers {
    static var monthlySubscription: String {
        switch FreespokeEnvironment.current {
        case .production, .staging:
            return "premium_monthly_v2"
        case .development:
            return "MonthlyRenewableSubscription_staging"
        }
    }
    
    static var yearlySubscription: String {
        switch FreespokeEnvironment.current {
        case .production, .staging:
            return "premium_annual_v2"
        case .development:
            return "YearlyRenewableSubscription_staging"
        }
    }
}

enum IAPManagerPurchasingStatus: Equatable {
    case canNotMakePayments
    case subscribed(product: Product)
    case failed(customMessage: String? = nil)
    case cancelled
    case storeProductNotAvailable
    
    var userMessage: String? {
        switch self {
        case .canNotMakePayments:
            return "Subscriptions are not available on current device"
        case .cancelled, .subscribed:
            return nil
        case .failed(let customMessage):
            return customMessage ?? "Subscription Failed"
        case .storeProductNotAvailable:
            return "Store Product Not Available"
        }
    }
}

enum IAPManagerRestorationStatus: Equatable {
    case canNotMakePayments
    case noTransactionsToRestore
    case restored
    case restorePurchasesFailed(customMessage: String? = nil)
    case storeProductNotAvailable
    case userCancelled
    
    var userMessage: String? {
        switch self {
        case .canNotMakePayments:
            return "Subscriptions are not available on current device"
        case .noTransactionsToRestore:
            return "We did not find any previous subscriptions to restore under this account."
        case .restorePurchasesFailed(let customMessage):
            return customMessage ?? "Restore Subscription Failed"
        case .restored:
            return "Your Subscription restored Successfully"
        case .storeProductNotAvailable:
            return "Store Product Not Available"
        case .userCancelled:
            return nil
        }
    }
}

protocol InAppManagerProtocol {
    var getProductsFinishedAction: PassthroughSubject<[Product], Never> { get set }
    
    func purchaseProduct(productIdentifier: String, appAccountToken: UUID, completion: @escaping((IAPManagerPurchasingStatus) -> Void))
    func restorePurchases(appAccountToken: UUID, completion: @escaping((IAPManagerRestorationStatus) -> Void))
    
    func requestProductsInfo()
    func restorePurchasesAtAppStart()
}
