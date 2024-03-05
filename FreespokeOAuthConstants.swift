// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

final class OAuthConstants {
    static var openIdIssuer: String {
        get {
            switch FreespokeEnvironment.current {
            case .production:
                return "https://auth.staging.freespoke.com/realms/freespoke-staging"
//                return "https://auth.freespoke.com/realms/freespoke"
            case .staging:
                return "https://auth.staging.freespoke.com/realms/freespoke-staging"
            }
        }
    }
    
    static let clientId = "mobile"
    static var callBackURLOAuthLogin: String {
        get {
            switch FreespokeEnvironment.current {
            case .production:
                return "com.freespoke:/iosappcallbackauth"
            case .staging:
                return "com.freespoke:/iosappcallbackauth"
            }
        }
    }
    
    static var callBackURLOAuthLogout: String {
        get {
            switch FreespokeEnvironment.current {
            case .production:
                return "com.freespoke:/iosappcallbacklogout"
            case .staging:
                return "com.freespoke:/iosappcallbacklogout"
            }
        }
    }
}
