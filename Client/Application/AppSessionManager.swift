// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

enum UserType {
    case authorizedWithoutPremium
    case premium
    case unauthorized
}

protocol AppSessionProvider {
    var tabUpdateState: TabUpdateState { get set }
    var launchSessionProvider: LaunchSessionProviderProtocol { get set }
    var downloadQueue: DownloadQueue { get }
    var decodedJWTToken: FreespokeJWTDecodeModel? { get }
    var userType: UserType { get }
    
    func performRegisterFreespokeUser(firstName: String, lastName: String, email: String, password: String, completion: @escaping (_ authModel: FreespokeAuthModel?, _ error: CustomError?) -> Void)
    func performFreespokeLogin(parentVC: UIViewController, successCompletion: (( _ apiAuthModel: FreespokeAuthModel) -> Void)?)
    func performSignInWithApple(successCompletion: (( _ apiAuthModel: FreespokeAuthModel) -> Void)?, failureCompletion: (( _ error: Error) -> Void)?)
    func performRefreshFreespokeToken(completion: (( _ apiAuthModel: FreespokeAuthModel?, _ error: Error?) -> Void)?)
    func performFreespokeLogout(completion: ((_ error: CustomError?) -> Void)?)
    func performFreespokeForceLogout()
}

/// `AppSessionManager` exists to track, mutate and (sometimes) persist session related properties. Each category of
/// items can be its own `Provider`.
///
/// DO NOT treat this as your go to solution for session property management. It will turn this session manager
/// into a smörgåsbord of countless properties. Consider all options before adding it here, but if it makes sense, go for it.
class AppSessionManager: AppSessionProvider {
    static let shared = AppSessionManager()
    
    var tabUpdateState: TabUpdateState = .coldStart
    var launchSessionProvider: LaunchSessionProviderProtocol
    var downloadQueue: DownloadQueue
    
    var decodedJWTToken: FreespokeJWTDecodeModel? {
        guard let decodeJWT = self.decodeJWTToken() else { return nil }
        return decodeJWT
    }
    
    var userType: UserType {
        if let decodedJWTToken = self.decodedJWTToken {
            if decodedJWTToken.isPremium {
                return .premium
            } else {
                return .authorizedWithoutPremium
            }
        } else {
            return .unauthorized
        }
    }
    
    // MARK: Authentication
    
    private var accessTokenRefreshTimer: Timer?
    
    private var authService = FreespokeAuthService()
    
    init(launchSessionProvider: LaunchSessionProvider = LaunchSessionProvider(),
         downloadQueue: DownloadQueue = DownloadQueue()) {
        self.launchSessionProvider = launchSessionProvider
        self.downloadQueue = downloadQueue
    }
    
    // MARK: Registration Freespoke User
    func performRegisterFreespokeUser(firstName: String, lastName: String, email: String, password: String, completion: @escaping (_ authModel: FreespokeAuthModel?, _ error: CustomError?) -> Void) {
        authService.performRegisterFreespokeUser(firstName: firstName,
                                                 lastName: lastName,
                                                 email: email,
                                                 password: password,
                                                 completion: completion)
    }
    
    // MARK: Login Freespoke User
    func performFreespokeLogin(parentVC: UIViewController, successCompletion: (( _ apiAuthModel: FreespokeAuthModel) -> Void)?) {
        authService.performLoginWithOAuth2(parentVC: parentVC,
                                           successCompletion: { apiAuthModel in
            successCompletion?(apiAuthModel)
        },
                                           failureCompletion: nil)
    }
    
    // MARK: Sign In With Apple Freespoke User
    func performSignInWithApple(successCompletion: (( _ apiAuthModel: FreespokeAuthModel) -> Void)?, failureCompletion: (( _ error: Error) -> Void)?) {
        authService.performAuthWithApple(successCompletion: { apiAuthModel in
            Keychain.authInfo = apiAuthModel
            successCompletion?(apiAuthModel)
        },
                                         failureCompletion: failureCompletion)
    }
    
    // MARK: Refresh Freespoke Token
    func performRefreshFreespokeToken(completion: (( _ apiAuthModel: FreespokeAuthModel?, _ error: Error?) -> Void)?) {
        self.authService.refreshToken(completion: { apiAuthModel, error in
            if let apiAuthModel = apiAuthModel {
                Keychain.authInfo = apiAuthModel
            } else {
                AppSessionManager.shared.performFreespokeForceLogout()
            }
            completion?(apiAuthModel, error)
        })
    }
    
    // MARK: Freespoke Logout
    func performFreespokeLogout(completion: ((_ error: CustomError?) -> Void)?) {
        self.authService.performLogoutFreespokeUser(completion: { error in
            print("TEST: Logout error: ", error?.localizedDescription ?? "logout error")
        })
        self.performFreespokeForceLogout()
    }
    
    // MARK: Freespoke Force Logout
    func performFreespokeForceLogout() {
        DispatchQueue.main.async {
            self.clearFreespokeAccountData()
            UIUtils.showOkAlert(title: "You've Been Logged Out",
                                message: "Please log back in.")
        }
    }
    
    // MARK: Access Token Expiration Handler
    func startAccessTokenExpirationHandler() {
        guard let accessTokenExpirationDate = self.decodedJWTToken?.exp else { return }
        
        // Calculate the time interval until expiration
        let timeIntervalUntilExpiration = accessTokenExpirationDate.timeIntervalSince(Date())
        
        // Create a timer to trigger token refresh when the access token expires
        self.accessTokenRefreshTimer = Timer.scheduledTimer(withTimeInterval: timeIntervalUntilExpiration, repeats: false) { [weak self] timer in
            self?.handleTokenExpiration()
        }
    }
    
    // MARK: Handle Token Expiration
    private func handleTokenExpiration() {
        // Check if the expiration date is in the past
        guard let expirationDate = self.decodedJWTToken?.exp, expirationDate < Date() else {
            // Token is still valid, no action needed
            return
        }
        
        // Call the refresh token API
        self.performRefreshFreespokeToken(completion: nil)
    }
    
    private func stopAccessTokenRefreshTimer() {
        self.accessTokenRefreshTimer?.invalidate()
        self.accessTokenRefreshTimer = nil
    }
    
    private func clearFreespokeAccountData() {
        self.stopAccessTokenRefreshTimer()
        Keychain.authInfo = nil
    }
    
    private func decodeJWTToken() -> FreespokeJWTDecodeModel? {
        guard let accessToken = Keychain.authInfo?.accessToken else { return nil }
        let jsonString = self.authService.decodeJwt(from: accessToken)
        
        guard let jsonData = jsonString.data(using: .utf8),
              let decodedModel = try? JSONDecoder().decode(FreespokeJWTDecodeModel.self, from: jsonData)
        else { return nil }
        
        return decodedModel
    }
}
