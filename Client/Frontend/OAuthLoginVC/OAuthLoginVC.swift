// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import WebKit
import AppAuth

class ApiAuthModel: NSObject {
    var accessToken = ""
    var refreshToken = ""

    var expiresIn = 0
    var tokenType = "Bearer"
    var id_token = ""
}

final class OAuthCallBackURLConstants {
    
    static var callBackURLOAuthLogin: String {
        get {
            switch FreespokeEnvironment.current {
            case .production:
                return "com.freespoke:/iosappcallbackauth"
            case .staging:
                return "com.freespoke:/iosappcallbackauth"
            }
        }
    }
    
    static var callBackURLOAuthLogout: String {
        get {
            switch FreespokeEnvironment.current {
            case .production:
                return "com.freespoke:/iosappcallbacklogout"
            case .staging:
                return "com.freespoke:/iosappcallbacklogout"
            }
        }
    }
    
}

class OAuthLoginVC: UIViewController {
    
    let webView = WKWebView()
    
    var request: OIDAuthorizationRequest?
    
    var oAuthAuthorizaionSucessfullCompletion: ((_ apiAuth: ApiAuthModel) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.navigationDelegate = self
        self.prepareUI()
        self.positionUIlements()
        self.startLoadingWebView(url: self.request?.authorizationRequestURL())
    }
    
    func prepareUI() {
        self.modalPresentationStyle = .overFullScreen
        self.view.backgroundColor = .white
    }
    
    func positionUIlements() {
        self.view.addSubview(webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        self.webView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        self.webView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        self.webView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
    
    func startLoadingWebView(url: URL?) {
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func handleCallbackUrl(callBackUrl: URL) {
        guard let request = self.request else { return }
        let components = URLComponents(url: callBackUrl, resolvingAgainstBaseURL: false)
        
        var parameters: [String: String] = [:]
        components?.queryItems?.forEach({ parameters[$0.name] = $0.value })
    
        guard let code = parameters["code"] else { return }
        guard let state = parameters["state"] else { return }
        guard let scope = parameters["scope"] else { return }
        
        
        let authorizationResponse = OIDAuthorizationResponse(request: request, parameters: [:])
        authorizationResponse.setValue(code, forKey: "authorizationCode")
        authorizationResponse.setValue(state, forKey: "state")
        authorizationResponse.setValue(scope, forKey: "scope")
        
        let tokenRequest = authorizationResponse.tokenExchangeRequest()
        
        OIDAuthorizationService.perform(tokenRequest!, callback: { [weak self] tokenResponse, error in
            guard let sSelf = self else { return }
            let apiAuth = ApiAuthModel()
            apiAuth.tokenType = tokenResponse?.tokenType ?? "Bearer"
            apiAuth.accessToken = tokenResponse?.accessToken ?? ""
            apiAuth.refreshToken = tokenResponse?.refreshToken ?? ""
            apiAuth.id_token = tokenResponse?.idToken ?? ""
            
//            AuthenticationManager.shared.apiAuth = apiAuth
            
            #if DEBUG
            print("====================================================================================")
            print("tokenResponse:\n", tokenResponse ?? "")
            print("====================================================================================")
            print("Got authorization tokenType. tokenType: \(apiAuth.tokenType)")
            print("======================")
            print("Got authorization accessToken. accessToken: \(apiAuth.accessToken)")
            print("======================")
            print("Got authorization refreshToken. Refresh token: \(apiAuth.refreshToken)")
            print("======================")
            print("Got authorization IdToken. IdToken: \(apiAuth.id_token)")
            print("====================================================================================")
            #endif
            
            sSelf.oAuthAuthorizaionSucessfullCompletion?(apiAuth)
//            sSelf.motionDismissViewController()
        })

    }
    
}

extension OAuthLoginVC: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        let loginCallBackUrl = "\(url.scheme ?? ""):\(url.relativePath)"

        if loginCallBackUrl == OAuthCallBackURLConstants.callBackURLOAuthLogin {
            print("loginCallBackUrl: ", loginCallBackUrl)
            handleCallbackUrl(callBackUrl: url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("loaded")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("We had error: \(error)")
    }
}


class AuthenticationManager: NSObject {
    static var shared = AuthenticationManager()
    
    func clearCache() {
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
}
