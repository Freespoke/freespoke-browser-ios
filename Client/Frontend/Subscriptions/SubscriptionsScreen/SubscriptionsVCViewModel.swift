// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
protocol SubscriptionsVCViewModelDelegate: AnyObject {
    
}
class SubscriptionsVCViewModel {
    enum State {
        case startTrialSubscription(isOnboarding: Bool)
        case trialExpired
        case updatePlan
        case cancelPlanNotOriginalOS
    }
    weak var delegate: SubscriptionsVCViewModelDelegate?
    var state: State
    
    var titleText: String {
        switch state {
        case .startTrialSubscription:
            return "Start your 30 day \n free trial"
        case .trialExpired:
            return "Select a Plan"
        case .updatePlan:
            return "Update Plan"
        case .cancelPlanNotOriginalOS:
            return "Update Plan"
        }
    }
    
    var subtitleText: String? {
        switch state {
        case .startTrialSubscription:
            return nil
        case .trialExpired:
            return "Cancel anytime."
        case .updatePlan:
            return "Cancel anytime."
        case .cancelPlanNotOriginalOS:
            return "Cancel anytime."
        }
    }
    
    var descriptionText: String? {
        switch state {
        case .startTrialSubscription:
            return "By tapping below for monthly or yearly subscription you are enrolling in automatic payments after the 30-day trial period. You can cancel anytime, effective at end of billing period."
        case .trialExpired:
            return nil
        case .updatePlan:
            return nil
        case .cancelPlanNotOriginalOS:
            return nil
        }
    }
    
    var btnContinueTitleText: String? {
        switch state {
        case .startTrialSubscription:
            return "Continue without premium"
        case .trialExpired:
            return "Continue without premium"
        case .updatePlan:
            return "Continue without Updating"
        case .cancelPlanNotOriginalOS:
            return "Continue without Updating"
        }
    }
    
    private var networkManager = NetworkManager()
    
    init(state: State) {
        self.state = state
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
}
