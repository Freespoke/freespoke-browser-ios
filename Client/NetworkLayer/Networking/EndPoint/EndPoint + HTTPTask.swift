import Foundation

extension EndPoint {
    var task: HTTPTask {
        switch self {
        case .registerFreespokeUser(let firstName, let lastName, let email, let password):
            let bodyParameters: HTTPParameters = [
                NetworkLayerConstants.ParameterKeys.firstName: firstName,
                NetworkLayerConstants.ParameterKeys.lastName: lastName,
                NetworkLayerConstants.ParameterKeys.email: email,
                NetworkLayerConstants.ParameterKeys.password: password,
                NetworkLayerConstants.ParameterKeys.magicLinkConfig: [
                    NetworkLayerConstants.ParameterKeys.clientId: NetworkLayerConstants.ParameterValues.publicValue,
                    NetworkLayerConstants.ParameterKeys.redirectUri: OAuthConstants.callBackURLOAuthRegisterAutoLogin,
                ]
            ]
            return .requestParametersAndHeaders(bodyParameters: bodyParameters,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: self.headers)
        case .logoutFreespokeUser:
            let bodyParameters: HTTPParameters = [
                NetworkLayerConstants.ParameterKeys.clientId: OAuthConstants.clientId,
                NetworkLayerConstants.ParameterKeys.refreshToken: Keychain.authInfo?.refreshToken ?? ""
            ]
            
            return .requestParametersAndHeaders(bodyParameters: bodyParameters,
                                                bodyEncoding: .formUrlencoded,
                                                urlParameters: nil,
                                                additionHeaders: self.headers)
        case .getLinkForManagingSubscription:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding(urlEncodingType: .none),
                                                urlParameters: nil,
                                                additionHeaders: self.headers)
        case .restorePurchase(let signedPayload):
            let bodyParameters: HTTPParameters = [
                NetworkLayerConstants.ParameterKeys.signedPayload: signedPayload
            ]
            
            return .requestParametersAndHeaders(bodyParameters: bodyParameters,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: self.headers)
        case .getBreakingNews(let page, let perPage):
            let parameters: HTTPParameters = [
                NetworkLayerConstants.ParameterKeys.page: page,
                NetworkLayerConstants.ParameterKeys.perPageCamelCased: perPage
            ]
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding(urlEncodingType: .none),
                                                urlParameters: parameters,
                                                additionHeaders: self.headers)
            
        case .getStoryFeed(let page, let perPage):
            let parameters: HTTPParameters = [
                NetworkLayerConstants.ParameterKeys.page: page,
                NetworkLayerConstants.ParameterKeys.perPageUnderscored: perPage,
                NetworkLayerConstants.ParameterKeys.features: "videos,documents,summary,similarity,articles,tweets,links",
            ]
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding(urlEncodingType: .none),
                                                urlParameters: parameters,
                                                additionHeaders: self.headers)
        case .getAdvertisement:
            let parameters: HTTPParameters = [
                NetworkLayerConstants.ParameterKeys.location: "homepage-ios",
            ]
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding(urlEncodingType: .none),
                                                urlParameters: parameters,
                                                additionHeaders: self.headers)
        case .getShoppingCollection(let page, let perPage):
            let parameters: HTTPParameters = [
                NetworkLayerConstants.ParameterKeys.page: page,
                NetworkLayerConstants.ParameterKeys.perPageUnderscored: perPage
            ]
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding(urlEncodingType: .none),
                                                urlParameters: parameters,
                                                additionHeaders: self.headers)
        }
    }
}
