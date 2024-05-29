// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import WebKit

enum UserType {
    case authorizedWithoutPremium
    case premiumOriginalApple
    case premiumNotApple
    case premiumBecauseAppleAccountHasSubscription
    case unauthorizedWithoutPremium
    case unauthorizedWithPremium
}

protocol AppSessionProvider {
    var tabUpdateState: TabUpdateState { get set }
    var launchSessionProvider: LaunchSessionProviderProtocol { get set }
    var downloadQueue: DownloadQueue { get }
    var decodedJWTToken: FreespokeJWTDecodeModel? { get }
    
    func userType() async throws -> UserType
    func performRegisterFreespokeUser(firstName: String, lastName: String, email: String, password: String, completion: @escaping (_ authModel: FreespokeAuthModel?, _ error: CustomError?) -> Void)
    func performAutoLogin(parentVC: UIViewController, linkURL: URL, successCompletion: (() -> Void)?, failureCompletion: (( _ error: Error?) -> Void)?)
    func performFreespokeLogin(parentVC: UIViewController, successCompletion: (( _ apiAuthModel: FreespokeAuthModel) -> Void)?)
    func performSignInWithApple(successCompletion: (( _ apiAuthModel: FreespokeAuthModel) -> Void)?, failureCompletion: (( _ error: Error) -> Void)?)
    func performRefreshFreespokeToken(completion: (( _ apiAuthModel: FreespokeAuthModel?, _ error: Error?) -> Void)?)
    func performFreespokeLogout(completion: ((_ error: CustomError?) -> Void)?)
    func performFreespokeForceLogout(showAlert: Bool)
    
    // web wrapper
    func webWrapperEventUserLoggedIn(authInfo: FreespokeAuthModel)
    func webWrapperEventUserLoggedOut()
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
    
    func userType() async throws -> UserType {
        if let decodedJWTToken = self.decodedJWTToken {
            let userTypeResult = Task<UserType, Error> {
                if let subscriptionType = try? await decodedJWTToken.subscriptionType() {
                    switch subscriptionType {
                    case .trialExpired:
                        return UserType.authorizedWithoutPremium
                    case .premiumOriginalApple:
                        return UserType.premiumOriginalApple
                    case .premiumBecauseAppleAccountHasSubscription:
                        return UserType.premiumBecauseAppleAccountHasSubscription
                    case .premiumNotApple:
                        return UserType.premiumNotApple
                    }
                } else {
                    return UserType.authorizedWithoutPremium
                }
            }
            return try await userTypeResult.value
        } else {
            let appleMonthlySubscription = InAppManager.shared.product(productId: ProductIdentifiers.monthlySubscription)
            let appleYearlySubscription = InAppManager.shared.product(productId: ProductIdentifiers.yearlySubscription)
            
            let premiumResult = Task<UserType, Error> {
                if (appleMonthlySubscription != nil) || (appleYearlySubscription != nil) {
                    // checking monthly subscription
                    if let appleMonthlySubscription = appleMonthlySubscription {
                        let isPurchasedResult = try await InAppManager.shared.isPurchased(appleMonthlySubscription.productID)
                        if isPurchasedResult.isPurchased {
                            return UserType.unauthorizedWithPremium
                        }
                    }
                    
                    // checking yearly subscription
                    if let appleYearlySubscription = appleYearlySubscription {
                        let isPurchasedResult = try await InAppManager.shared.isPurchased(appleYearlySubscription.productID)
                        if isPurchasedResult.isPurchased {
                            return UserType.unauthorizedWithPremium
                        }
                    }
                }
                
                return UserType.unauthorizedWithoutPremium
            }
            return try await premiumResult.value
        }
    }
    
    func checkIsUserHasPremium(isPremiumCompletion: ((_ isPremium: Bool) -> Void)?) {
        Task {
            do {
                if let userType = try? await self.userType() {
                    switch userType {
                    case .authorizedWithoutPremium:
                        isPremiumCompletion?(false)
                    case .premiumOriginalApple, .premiumNotApple, .premiumBecauseAppleAccountHasSubscription:
                        isPremiumCompletion?(true)
                    case .unauthorizedWithoutPremium:
                        isPremiumCompletion?(false)
                    case .unauthorizedWithPremium:
                        isPremiumCompletion?(true)
                    }
                }
            }
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
    
    // MARK: - Auto Login
    func performAutoLogin(parentVC: UIViewController, linkURL: URL, successCompletion: (() -> Void)?, failureCompletion: (( _ error: Error?) -> Void)?) {
        authService.performAutoLogin(parentVC: parentVC, linkURL: linkURL, successCompletion: successCompletion, failureCompletion: failureCompletion)
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
                if self.decodedJWTToken?.accessTokenExpiredAlready == true {
                    AppSessionManager.shared.performFreespokeForceLogout(showAlert: true)
                }
            }
            completion?(apiAuthModel, error)
        })
    }
    
    // MARK: Freespoke Logout
    func performFreespokeLogout(completion: ((_ error: CustomError?) -> Void)?) {
        self.authService.performLogoutFreespokeUser(completion: { error in
            print("TEST: Logout error: ", error?.localizedDescription ?? "logout error")
            completion?(error)
        })
        self.performFreespokeForceLogout(showAlert: true)
    }
    
    // MARK: Freespoke Force Logout
    func performFreespokeForceLogout(showAlert: Bool) {
        DispatchQueue.main.async {
            self.clearFreespokeAccountData()
            if showAlert {
                UIUtils.showOkAlertInNewWindow(title: "You've Been Logged Out",
                                               message: "Please log back in.")
            }
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
        self.clearCache()
    }
    
    private func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        HTTPCookieStorage.shared.cookies?.forEach { cookie in
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
        print("[WebCacheCleaner] All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("[WebCacheCleaner] Record \(record) deleted")
            }
        }
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

// MARK: - Web wrapper events

extension AppSessionManager {
    func webWrapperEventUserLoggedIn(authInfo: FreespokeAuthModel) {
        Keychain.authInfo = authInfo
    }
    
    func webWrapperEventUserLoggedOut() {
        self.performFreespokeForceLogout(showAlert: false)
    }
    
    func webWrapperEventUserAccountUpdated() {
        self.performRefreshFreespokeToken(completion: nil)
    }
    
    func webWrapperEventUserDeactivatedAccount() {
        self.performFreespokeForceLogout(showAlert: false)
    }
}
