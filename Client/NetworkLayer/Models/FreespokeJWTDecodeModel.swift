// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

struct FreespokeJWTDecodeModel {
    let scope: String
    let emailVerified: Bool
    let name: String
    let preferredUsername: String
    let givenName: String
    let familyName: String
    let email: String
    var externalAccountId: UUID?
    let subscription: SubscriptionInfo?
    
    var isPremium: Bool {
        switch self.subscription?.subscriptionType {
        case .free,
                .freeTrial,
                .premium:
            return true
        default:
            return false
        }
    }
    
    func getInitialsLetters() -> String {
        let firstNameLetter = self.givenName.prefix(1)
        let lastNameLetter = self.familyName.prefix(1)
        return "\(firstNameLetter)\(lastNameLetter)"
    }
}

// MARK: - Codable

extension FreespokeJWTDecodeModel: Codable {
    private enum CodingKeys: String, CodingKey {
        case scope
        case emailVerified = "email_verified"
        case name = "name"
        case preferredUsername = "preferred_username"
        case givenName = "given_name"
        case familyName = "family_name"
        case email = "email"
        case externalAccountId = "external_account_id"
        case subscription = "subscription"
    }
}

struct SubscriptionInfo: Codable {
    enum SubscriptionType: String {
        case free = "free"
        case freeTrial = "free trial"
        case premium = "premium"
    }
    
    enum SubscriptionSource: String {
        case ios = "ios-native"
        case android = "android-native"
        case web = "web-recurly"
    }
    
    private let subscriptionName: String
    let subscriptionPaymentAmount: Int
    let subscriptionPaymentCurrency: String
    let subscriptionPaymentSource: String
    let subscriptionExpiry: Date?
    
    var subscriptionType: SubscriptionType? {
        SubscriptionType(rawValue: self.subscriptionName)
    }
    var subscriptionSource: SubscriptionSource? {
        SubscriptionSource(rawValue: self.subscriptionPaymentSource)
    }
}
