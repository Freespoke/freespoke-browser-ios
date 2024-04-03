import Foundation

extension EndPoint {
    var headers: HTTPHeaders? {
        switch self {
        case .registerFreespokeUser:
            return [NetworkLayerConstants.HeaderKeys.xClientSecret: NetworkLayerConstants.xClientSecretValue]
        case .logoutFreespokeUser:
            return [NetworkLayerConstants.HeaderKeys.authorization: "\(NetworkLayerConstants.HeaderKeys.bearer) \(Keychain.authInfo?.accessToken ?? "")",
                    NetworkLayerConstants.HeaderKeys.contentType: NetworkLayerConstants.HeaderValue.applicationFormUrlencoded
            ]
        case .getLinkForManagingSubscription:
            return [NetworkLayerConstants.HeaderKeys.authorization: "\(NetworkLayerConstants.HeaderKeys.bearer) \(Keychain.authInfo?.accessToken ?? "")"]
        case .restorePurchase:
            return [NetworkLayerConstants.HeaderKeys.authorization: "\(NetworkLayerConstants.HeaderKeys.bearer) \(Keychain.authInfo?.accessToken ?? "")",
                    NetworkLayerConstants.HeaderKeys.contentType: NetworkLayerConstants.HeaderValue.applicationJson
            ]
        }
    }
}
