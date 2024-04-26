import Foundation

enum EndPoint {
    case registerFreespokeUser(firstName: String, lastName: String, email: String, password: String)
    case logoutFreespokeUser
    case getLinkForManagingSubscription
    case restorePurchase(signedPayload: String)
    case getShoppingCollection(page: Int, perPage: Int)
}

extension EndPoint: EndPointType {
    var baseURL: URL {
        switch self {
        case .registerFreespokeUser,
                .getLinkForManagingSubscription,
                .restorePurchase,
                .getShoppingCollection:
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
        case .getLinkForManagingSubscription:
            return NetworkLayerConstants.PathURLs.getLinkForManagingSubscriptionPath
        case .restorePurchase:
            return NetworkLayerConstants.PathURLs.restorePurchasePath
        case .getShoppingCollection:
            return NetworkLayerConstants.PathURLs.getShoppingCollectionPath
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .registerFreespokeUser,
                .logoutFreespokeUser,
                .restorePurchase:
            return .post
        case .getLinkForManagingSubscription,
                .getShoppingCollection:
            return .get
        }
    }
}
