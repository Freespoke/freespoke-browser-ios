

import Foundation

enum NetworkLayerConstants {
    static var xClientSecretValue: String {
        switch FreespokeEnvironment.current {
        case .production:
            return ""
        case .staging:
            return "cce90e80e99383e2fe5c39b42f73b5c3"
        }
    }
    
    // MARK: Network Layer Constants - Base URL
    
    enum BaseURL {
        static var baseServerUrl: String {
            switch FreespokeEnvironment.current {
            case .production:
                return "https://api.freespoke.com"
            case .staging:
                return "https://api.staging.freespoke.com"
            }
        }
        
        static var oAuthBaseUrl: String {
            switch FreespokeEnvironment.current {
            case .production:
                return "https://auth.freespoke.com"
            case .staging:
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
            case .staging:
                return "/accounts/register/ios"
            }
        }
        
        static var logoutPath: String {
            switch FreespokeEnvironment.current {
            case .production:
                return "/realms/freespoke/protocol/openid-connect/logout"
            case .staging:
                return "/realms/freespoke-staging/protocol/openid-connect/logout"
            }
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
    }
}
