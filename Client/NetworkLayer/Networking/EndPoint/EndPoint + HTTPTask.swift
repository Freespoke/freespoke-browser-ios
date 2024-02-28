import Foundation

extension EndPoint {
    var task: HTTPTask {
        switch self {
        case .registerFreespokeUser(let firstName, let lastName, let email, let password):
            let bodyParameters: HTTPParameters = [
                NetworkLayerConstants.ParameterKeys.firstName: firstName,
                NetworkLayerConstants.ParameterKeys.lastName: lastName,
                NetworkLayerConstants.ParameterKeys.email: email,
                NetworkLayerConstants.ParameterKeys.password: password
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
        }
    }
}
