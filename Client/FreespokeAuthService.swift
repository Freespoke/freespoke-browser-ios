// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import AppAuth

class FreespokeAuthService {
    private var networkManager = NetworkManager()
    
    // MARK: - Registration
    func performRegisterFreespokeUser(firstName: String, lastName: String, email: String, password: String, completion: @escaping (_ authModel: FreespokeAuthModel?, _ error: CustomError?) -> Void) {
        self.networkManager.registerFreespokeUser(firstName: firstName,
                                                  lastName: lastName,
                                                  email: email,
                                                  password: password,
                                                  completion: completion)
    }
    
    // MARK: - Login
    func performLoginWithOAuth2(parentVC: UIViewController, successCompletion: (( _ apiAuthModel: FreespokeAuthModel) -> Void)?, failureCompletion: (( _ error: Error?) -> Void)?) {
        guard let issuer = URL(string: OAuthConstants.openIdIssuer),
              let callBackURL = URL(string: OAuthConstants.callBackURLOAuthLogin) else {
            return
        }
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer,
                                                      completion: { configuration, error in
            guard let configuration = configuration else { return }
            
            let request = OIDAuthorizationRequest(configuration: configuration,
                                                  clientId: OAuthConstants.clientId,
                                                  scopes: [OIDScopeOpenID],
                                                  redirectURL: callBackURL,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: nil)
            DispatchQueue.main.async {
                let vc = OAuthLoginVC()
                vc.request = request
                
                vc.oAuthAuthorizaionCompletion = { [weak vc] authModel, error in
                    if let authModel = authModel {
                        vc?.motionDismissViewController()
                        successCompletion?(authModel)
                    } else {
                        vc?.motionDismissViewController()
                        failureCompletion?(error ?? CustomError.somethingWentWrong)
                    }
                }
                parentVC.present(vc, animated: true, completion: nil)
            }
        })
    }
    
    // MARK: - Authentication with Apple account
    func performAuthWithApple(successCompletion: (( _ apiAuthModel: FreespokeAuthModel) -> Void)?, failureCompletion: (( _ error: Error) -> Void)?) {
        guard let issuer = URL(string: OAuthConstants.openIdIssuer),
              let callBackURL = URL(string: OAuthConstants.callBackURLOAuthLogin) else {
            return
        }
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer,
                                                      completion: { configuration, error in
            guard let configuration = configuration else { return }
            
            let request = OIDAuthorizationRequest(configuration: configuration,
                                                  clientId: OAuthConstants.clientId,
                                                  scopes: [OIDScopeOpenID],
                                                  redirectURL: callBackURL,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: ["kc_idp_hint": "apple"])
            
            print("TEST: OIDAuthorizationService perform request: ", request)
            
            DispatchQueue.main.async {
                let vc = OAuthLoginVC()
                vc.request = request
                vc.oAuthAuthorizaionCompletion = { [weak vc] authModel, error in
                    if let authModel = authModel {
                        print("TEST: authModel: ", authModel)
                        print("TEST: authModel.accessToken: ", authModel.accessToken)
                        vc?.motionDismissViewController()
                        successCompletion?(authModel)
                    } else {
                        vc?.motionDismissViewController()
                        failureCompletion?(error ?? CustomError.somethingWentWrong)
                    }
                }
                guard let topMostVC = UIApplication.shared.keyWindowPresentedController() else { return }
                topMostVC.present(vc, animated: true, completion: nil)
            }
        })
    }
    
    // MARK: - Refresh Token
    func refreshToken(completion: (( _ apiAuthModel: FreespokeAuthModel?, _ error: Error?) -> Void)?) {
        guard let issuer = URL(string: OAuthConstants.openIdIssuer) else { return }
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer,
                                                      completion: { configuration, error in
            guard let configuration = configuration,
                    let refreshToken = Keychain.authInfo?.refreshToken else {
                AppSessionManager.shared.performFreespokeForceLogout()
                return
            }
            
            let request = OIDTokenRequest(
                configuration: configuration,
                grantType: OIDGrantTypeRefreshToken,
                authorizationCode: nil,
                redirectURL: nil,
                clientID: OAuthConstants.clientId,
                clientSecret: nil,
                scope: nil,
                refreshToken: refreshToken,
                codeVerifier: nil,
                additionalParameters: nil)
            
            OIDAuthorizationService.perform(request, callback: { tokenResponse, error in
                guard let tokenResponse = tokenResponse else { return }
                guard let idToken = tokenResponse.idToken else { return }
                guard let accessToken = tokenResponse.accessToken else { return }
                guard let refreshToken = tokenResponse.refreshToken else { return }
                
                let apiAuth = FreespokeAuthModel(id: idToken,
                                                 accessToken: accessToken,
                                                 refreshToken: refreshToken)
                completion?(apiAuth, error)
            })
        })
    }
    
    // MARK: - Logout
    func performLogoutFreespokeUser(completion: ((_ error: CustomError?) -> Void)?) {
        self.networkManager.logoutFreespokeUser(completion: completion)
    }
    
    // MARK: - Decode Jwt
    func decodeJwt(from jwt: String) -> String {
        let segments = jwt.components(separatedBy: ".")
        
        var base64String = segments[1]
        
        let requiredLength = Int(4 * ceil(Float(base64String.count) / 4.0))
        let nbrPaddings = requiredLength - base64String.count
        if nbrPaddings > 0 {
            let padding = String().padding(toLength: nbrPaddings, withPad: "=", startingAt: 0)
            base64String = base64String.appending(padding)
        }
        base64String = base64String.replacingOccurrences(of: "-", with: "+")
        base64String = base64String.replacingOccurrences(of: "_", with: "/")
        let decodedData = Data(base64Encoded: base64String, options: Data.Base64DecodingOptions(rawValue: UInt(0)))
        
        let base64Decoded: String = String(data: decodedData! as Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        return base64Decoded
    }
}
