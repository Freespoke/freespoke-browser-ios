// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

struct ManagingSubscriptionModel: Codable {
    let attributes: Attributes?
    let firstName: String?
    let lastName: String?
    let email: String?
    let manageSubscriptionLink: String?
    
    struct Attributes: Codable {
        let externalAccountId: String?
        let registrationPlatform: String?
        let subscription: Subscription?
        
        enum CodingKeys: String, CodingKey {
            case externalAccountId = "external_account_id"
            case registrationPlatform = "registrationPlatform"
            case subscription = "subscription"
        }
    }
    
    struct Subscription: Codable {
        let subscriptionName: String?
        let subscriptionPaymentAmount: Double?
        let subscriptionPaymentCurrency: String?
        let subscriptionPaymentSource: String?
        let subscriptionExpiry: TimeInterval?
    }
}
