// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Combine

protocol SubscriptionsVCViewModelDelegate: AnyObject {
    func premiumSuccessfullyUnlocked()
}
class SubscriptionsVCViewModel {
    weak var delegate: SubscriptionsVCViewModelDelegate?
    
    @Published private(set) var subscriptionType: SubscriptionType?
    
    private var cancellables = Set<AnyCancellable>()
    
    var isOnboarding: Bool
    
    var titleText: String {
        switch subscriptionType {
        case .trialExpired:
            return "Select a Plan"
        case .originalApple:
            return "Update Plan"
        case .notApple:
            return "Update Plan"
        case nil:
            return "Start your 30 day \n free trial"
        }
    }
    
    var subtitleText: String? {
        switch subscriptionType {
        case .trialExpired,
                .originalApple,
                .notApple:
            return "Cancel anytime."
        case nil:
            return nil
        }
    }
    
    var descriptionText: String? {
        switch subscriptionType {
        case .trialExpired,
                .originalApple,
                .notApple:
            return nil
        case nil:
            return "By tapping below for monthly or yearly subscription you are enrolling in automatic payments after the 30-day trial period. You can cancel anytime, effective at end of billing period."
        }
    }
    
    var btnContinueTitleText: String? {
        switch subscriptionType {
        case .trialExpired:
            return "Continue without premium"
        case .originalApple,
                .notApple:
            return "Continue without Updating"
        case nil:
            return "Continue without premium"
        }
    }
    
    private var networkManager = NetworkManager()
    
    var appAccountToken: UUID? {
        return AppSessionManager.shared.decodedJWTToken?.externalAccountId
    }
    
    var monthlySubscription: CustomProduct? {
        InAppManager.shared.product(productId: ProductIdentifiers.monthlySubscription)
    }
    
    var yearlySubscription: CustomProduct? {
        InAppManager.shared.product(productId: ProductIdentifiers.yearlySubscription)
    }
    
    init(isOnboarding: Bool) {
        self.isOnboarding = isOnboarding
        self.updateCurrentSubscriptionsState()
        self.subscribeToProductsReceivedPublisher()
        InAppManager.shared.requestProductsInfo()
    }
    
    private func updateCurrentSubscriptionsState() {
        Task {
            if let subscriptionType = try? await AppSessionManager.shared.decodedJWTToken?.subscriptionType() {
                self.subscriptionType = subscriptionType
            } else {
                self.subscriptionType = nil
            }
        }
    }
    
    func getLinkForManagingSubscription(onSuccess: @escaping((_ managingSubscriptionModel: ManagingSubscriptionModel) -> Void), onFailure: @escaping((_ error: CustomError) -> Void)) {
        self.networkManager.getLinkForManagingSubscription(completion: { managingSubscriptionModel, error in
            if let managingSubscriptionModel = managingSubscriptionModel {
                onSuccess(managingSubscriptionModel)
            } else if let error = error {
                onFailure(error)
            } else {
                onFailure(CustomError.somethingWentWrong)
            }
        })
    }
    
    func restorePurchases(completion: ((IAPManagerRestorationStatus) -> Void)? = nil) {
        guard let appAccountToken = self.appAccountToken else {
            UIUtils.showOkAlertInNewWindow(title: "appAccountToken is nil", message: "")
            completion?(.restorePurchasesFailed(customMessage: "appAccountToken is nil"))
            return
        }
        InAppManager.shared.restorePurchases(appAccountToken: appAccountToken,
                                             completion: { status in
            if let userMessage = status.userMessage {
                UIUtils.showOkAlertInNewWindow(title: userMessage, message: "")
            }
            if case .restored = status {
                AppSessionManager.shared.performRefreshFreespokeToken(completion: { authResponse, error in
                    if error == nil {
                        self.updateCurrentSubscriptionsState()
                    }
                })
            }
            completion?(status)
        })
    }
}

// MARK: Products Received Subscription

extension SubscriptionsVCViewModel {
    func subscribeToProductsReceivedPublisher() {
        InAppManager.shared.getProductsFinishedAction
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                guard let self = self else { return }
                self.updateCurrentSubscriptionsState()
            }
            .store(in: &self.cancellables)
    }
}

// MARK: Purchases

extension SubscriptionsVCViewModel {
    func purchaseMonthlySubscription(completion: @escaping((IAPManagerPurchasingStatus) -> Void)) {
        guard let appAccountToken = self.appAccountToken else {
            completion(.failed())
            return
        }
        if let monthlySubscription = self.monthlySubscription {
            InAppManager.shared.purchaseProduct(productIdentifier: monthlySubscription.productID,
                                                appAccountToken: appAccountToken,
                                                completion: { [weak self] status in
                guard let self = self else { return }
                
                if case .subscribed(let product) = status {
                    AppSessionManager.shared.performRefreshFreespokeToken(completion: nil)
                    self.delegate?.premiumSuccessfullyUnlocked()
                }
                completion(status)
            })
        } else {
            completion(.failed())
        }
    }
    
    func purchaseYearlySubscription(completion: @escaping((IAPManagerPurchasingStatus) -> Void)) {
        guard let appAccountToken = self.appAccountToken else {
            completion(.failed())
            return
        }
        if let yearlySubscription = self.yearlySubscription {
            InAppManager.shared.purchaseProduct(productIdentifier: yearlySubscription.productID,
                                                appAccountToken: appAccountToken,
                                                completion: { [weak self] status in
                guard let self = self else { return }
                
                if case .subscribed(let product) = status {
                    AppSessionManager.shared.performRefreshFreespokeToken(completion: nil)
                    self.delegate?.premiumSuccessfullyUnlocked()
                }
                completion(status)
            })
        } else {
            completion(.failed())
        }
    }
}
