// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import WebKit
import AppAuth

class OAuthLoginVC: UIViewController {
    private let webView = WKWebView()
    
    var request: OIDAuthorizationRequest?
    
    var oAuthAuthorizaionCompletion: ((_ apiAuth: FreespokeAuthModel?, _ error: Error?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.navigationDelegate = self
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
        self.startLoadingWebView(url: self.request?.authorizationRequestURL())
    }
    
    private func prepareUI() {
        self.modalPresentationStyle = .overFullScreen
        self.view.backgroundColor = .white
    }
    
    private func addingViews() {
        self.view.addSubview(self.webView)
    }
    
    private func setupConstraints() {
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.pinToView(view: self.view, safeAreaLayout: true, withInsets: UIEdgeInsets(equalInset: 0))
    }
    
    func startLoadingWebView(url: URL?) {
        if let url = url {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
    
    func handleCallbackUrl(callBackUrl: URL) {
        guard let request = self.request else { return }
        let components = URLComponents(url: callBackUrl, resolvingAgainstBaseURL: false)
        
        var parameters: [String: String] = [:]
        components?.queryItems?.forEach({ parameters[$0.name] = $0.value })
        
        guard let code = parameters["code"] else { return }
        guard let state = parameters["state"] else { return }
        
        let authorizationResponse = OIDAuthorizationResponse(request: request, parameters: [:])
        authorizationResponse.setValue(code, forKey: "authorizationCode")
        authorizationResponse.setValue(state, forKey: "state")
        authorizationResponse.setValue("openid profile email", forKey: "scope")
        
        let tokenRequest = authorizationResponse.tokenExchangeRequest()
        
        OIDAuthorizationService.perform(tokenRequest!, callback: { [weak self] tokenResponse, error in
            guard let sSelf = self else { return }
            if let error = error {
                sSelf.oAuthAuthorizaionCompletion?(nil, error)
            } else {
                guard let idToken = tokenResponse?.idToken,
                      let accessToken = tokenResponse?.accessToken,
                      let refreshToken = tokenResponse?.refreshToken
                else {
                    sSelf.oAuthAuthorizaionCompletion?(nil, CustomError.somethingWentWrong)
                    return
                }
                
                let apiAuth = FreespokeAuthModel(id: idToken,
                                                 accessToken: accessToken,
                                                 refreshToken: refreshToken)
                Keychain.authInfo = apiAuth
                sSelf.oAuthAuthorizaionCompletion?(apiAuth, nil)
            }
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
        
        if loginCallBackUrl == OAuthConstants.callBackURLOAuthLogin {
            self.handleCallbackUrl(callBackUrl: url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("TEST: loaded")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("TEST: We had error: \(error)")
    }
}
