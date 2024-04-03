// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

enum SubscriptionType {
    case trialExpired
    case originalApple
    case notApple
}

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
    let exp: Date?
    
    var accessTokenExpiredAlready: Bool {
        if let expirationDate = self.exp, expirationDate < Date() {
            return true
        } else {
            return false
        }
    }
    
    func subscriptionType() async throws -> SubscriptionType? {
        let monthlySubscription = InAppManager.shared.product(productId: ProductIdentifiers.monthlySubscription)
        let yearlySubscription = InAppManager.shared.product(productId: ProductIdentifiers.yearlySubscription)
        
        let premiumResult = Task<SubscriptionType?, Error> {
            if (monthlySubscription != nil) || (yearlySubscription != nil) {
                // checking monthly subscription
                if let monthlySubscription = monthlySubscription {
                    let isPurchased = try await InAppManager.shared.isPurchased(monthlySubscription.productID)
                    if isPurchased {
                        return .originalApple
                    }
                }
                
                // checking yearly subscription
                if let yearlySubscription = yearlySubscription {
                    let isPurchased = try await InAppManager.shared.isPurchased(yearlySubscription.productID)
                    if isPurchased {
                        return .originalApple
                    }
                }
                return self.checkIsPremiumUsingAccessToken()
            } else {
                return self.checkIsPremiumUsingAccessToken()
            }
        }
        
        // Wait for the result of the asynchronous task
        return try await premiumResult.value
    }
    
    private func checkIsPremiumUsingAccessToken() -> SubscriptionType? {
        switch self.subscription?.subscriptionSource {
        case .ios:
            switch self.subscription?.subscriptionType {
            case .free,
                    .freeTrial,
                    .premium:
                if let expiryDate = self.subscription?.subscriptionExpiry,
                   expiryDate < Date() {
                    return .trialExpired
                } else {
                    return .originalApple
                }
            default:
                return nil
            }
        case nil:
            switch self.subscription?.subscriptionType {
            case .free,
                    .freeTrial,
                    .premium:
                if let expiryDate = self.subscription?.subscriptionExpiry,
                   expiryDate < Date() {
                    return .trialExpired
                } else {
                    return .notApple
                }
            default:
                return nil
            }
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
        case exp = "exp"
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
