

import Foundation

enum NetworkLayerConstants {
    static var xClientSecretValue: String {
        switch FreespokeEnvironment.current {
        case .production:
            return "cce90e80e99383e2fe5c39b42f73b5c3"
        case .staging, .development:
            return "cce90e80e99383e2fe5c39b42f73b5c3"
        }
    }
    
    // MARK: Network Layer Constants - Base URL
    
    enum BaseURL {
        static var baseServerUrl: String {
            switch FreespokeEnvironment.current {
            case .production:
                //                return "https://api.staging.freespoke.com"
                return "https://api.freespoke.com"
            case .staging, .development:
                return "https://api.staging.freespoke.com"
            }
        }
        
        static var oAuthBaseUrl: String {
            switch FreespokeEnvironment.current {
            case .production:
                //                return "https://auth.staging.freespoke.com"
                return "https://accounts.freespoke.com"
            case .staging, .development:
                return "https://auth.staging.freespoke.com"
            }
        }
    }
    
    // MARK: Paths
    
    enum PathURLs {
        static var registerPath: String {
            switch FreespokeEnvironment.current {
            case .production:
                return "/accounts/register/ios"
            case .staging, .development:
                return "/accounts/register/ios"
            }
        }
        
        static var logoutPath: String {
            switch FreespokeEnvironment.current {
            case .production:
                //                return "/realms/freespoke-staging/protocol/openid-connect/logout"
                return "/realms/freespoke/protocol/openid-connect/logout"
            case .staging, .development:
                return "/realms/freespoke-staging/protocol/openid-connect/logout"
            }
        }
        
        static var getLinkForManagingSubscriptionPath: String {
            return "/accounts/profile"
        }
        
        static var restorePurchasePath: String {
            return "/accounts/restore-purchase/ios"
        }
        
        static var getShoppingCollectionPath: String {
            return "/v2/shop/collections"
        }
    }
    
    // MARK: Header Keys
    
    enum HeaderKeys {
        static let xClientSecret = "x-client-secret"
        static let authorization = "Authorization"
        static let bearer = "Bearer"
        static let contentType = "Content-Type"
    }
    
    // MARK: Header Values
    
    enum HeaderValue {
        static let applicationJson = "application/json"
        static let applicationFormUrlencoded = "application/x-www-form-urlencoded"
    }
    
    // MARK: Parameter Keys
    
    enum ParameterKeys {
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let email = "email"
        static let password = "password"
        static let clientId = "client_id"
        static let refreshToken = "refresh_token"
        static let signedPayload = "signedPayload"
        static let page = "page"
        static let perPage = "per_page"
        static let magicLinkConfig = "magic_link_config"
        static let redirectUri = "redirect_uri"
    }
    
    // MARK: Parameter Values

    enum ParameterValues {
        static let publicValue = "public"
    }
}
