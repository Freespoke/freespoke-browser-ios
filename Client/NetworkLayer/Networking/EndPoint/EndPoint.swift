import Foundation

enum EndPoint {
    case registerFreespokeUser(firstName: String, lastName: String, email: String, password: String)
    case logoutFreespokeUser
}

extension EndPoint: EndPointType {
    var baseURL: URL {
        switch self {
        case .registerFreespokeUser:
            guard let url = URL(string: NetworkLayerConstants.BaseURL.baseServerUrl) else {
                fatalError("baseServerUrl could not be configured.")
            }
            return url
        case .logoutFreespokeUser:
            guard let url = URL(string: NetworkLayerConstants.BaseURL.oAuthBaseUrl) else {
                fatalError("baseServerUrl could not be configured.")
            }
            return url
        }
    }
    
    var path: String {
        switch self {
        case .registerFreespokeUser:
            return NetworkLayerConstants.PathURLs.registerPath
        case .logoutFreespokeUser:
            return NetworkLayerConstants.PathURLs.logoutPath
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .registerFreespokeUser, .logoutFreespokeUser:
            return .post
        }
    }
}