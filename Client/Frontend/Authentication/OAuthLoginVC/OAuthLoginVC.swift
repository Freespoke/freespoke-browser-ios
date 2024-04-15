// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import WebKit
import AppAuth
import Shared
import Common

class OAuthLoginVC: UIViewController {
    enum OAuthLoginSource {
        case generalLogin
        case signInWithApple
        case accountPage
    }
    
    private var btnClose: UIButton = {
        let btn = UIButton()
        btn.layer.zPosition = 10
        return btn
    }()
    
    private var topBackgroundView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var webView = WKWebView()
    private var loadingIndicatorView: UIImageView?
    private var loadingIndicatorImageName: String = "freespoke_loader_torch_light"
    
    private var activityIndicatorEnabled: Bool
    
    private var source: OAuthLoginSource
    
    private var shouldAutoClose: Bool = false
    
    private let profile: Profile = AppContainer.shared.resolve()
    
    private lazy var tabManager: TabManager = TabManager(profile: profile,
                                                         imageStore: nil)
    
    private var currentTheme: Theme? {
        if let appDelegate = UIApplication.shared.delegate as?  AppDelegate {
            return appDelegate.themeManager.currentTheme
        }
        return nil
    }
    
    var authorizationRequest: OIDAuthorizationRequest?
    var oAuthAuthorizaionCompletion: ((_ apiAuth: FreespokeAuthModel?, _ error: Error?) -> Void)?
    
    init(activityIndicatorEnabled: Bool, source: OAuthLoginSource) {
        self.activityIndicatorEnabled = activityIndicatorEnabled
        self.source = source
        
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .formSheet
        
        self.createWebview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createWebview() {
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        configuration.userContentController = contentController
        configuration.websiteDataStore = .nonPersistent()
        configuration.userContentController = contentController
        
        self.tabManager.selectTab(tabManager.addTab())
        
        self.webView = tabManager.selectedTab!.webView!
        
        self.webView.accessibilityLabel = .WebViewAccessibilityLabel
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.allowsLinkPreview = true
        self.webView.navigationDelegate = self
        
        // Freespoke events
        
        guard let selectedTab = self.tabManager.selectedTab else { return }
        
        let freespokeLoginHelper = FreespokeAuthEventLoginHelper(tab: selectedTab)
        freespokeLoginHelper.delegate = self
        selectedTab.addContentScriptToPage(freespokeLoginHelper, name: FreespokeAuthEventLoginHelper.name())
        
        let freespokeLogoutHelper = FreespokeAuthEventLogoutHelper(tab: selectedTab)
        freespokeLogoutHelper.delegate = self
        selectedTab.addContentScriptToPage(freespokeLogoutHelper, name: FreespokeAuthEventLogoutHelper.name())
        
        let freespokeAccountUpdatedHelper = FreespokeAuthEventAccountUpdatedHelper(tab: selectedTab)
        freespokeAccountUpdatedHelper.delegate = self
        selectedTab.addContentScriptToPage(freespokeAccountUpdatedHelper, name: FreespokeAuthEventAccountUpdatedHelper.name())
        
        let freespokeDeactivateAccountHelper = FreespokeAuthEventDeactivateAccountHelper(tab: selectedTab)
        freespokeDeactivateAccountHelper.delegate = self
        selectedTab.addContentScriptToPage(freespokeDeactivateAccountHelper, name: FreespokeAuthEventDeactivateAccountHelper.name())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
        if let request = self.authorizationRequest {
            self.startLoadingWebView(url: request.authorizationRequestURL())
        }
        switch self.source {
        case .signInWithApple:
            self.subscribeToNotifications()
        case .accountPage, .generalLogin:
            break
        }
    }
    
    private func addCloseButton() {
        guard self.btnClose.superview == nil else { return }
        
        self.view.addSubview(self.topBackgroundView)
        self.view.addSubview(self.btnClose)
        
        self.addTopBackgroundViewConstraints()
        self.addCloseButtonConstraints()
        
        self.addCloseAction()
    }
    
    private func addTopBackgroundViewConstraints() {
        self.topBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.topBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            self.topBackgroundView.bottomAnchor.constraint(equalTo: self.webView.topAnchor, constant: 0)
        ])
    }
    
    private func addCloseButtonConstraints() {
        self.btnClose.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.btnClose.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.btnClose.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            self.btnClose.heightAnchor.constraint(equalToConstant: 50),
            self.btnClose.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            self.webView.isOpaque = false
            switch theme.type {
            case .dark:
                self.view.backgroundColor = UIColor.darkBackground
                self.topBackgroundView.backgroundColor = UIColor.darkBackground
                self.webView.backgroundColor = UIColor.darkBackground
                self.webView.scrollView.backgroundColor = UIColor.darkBackground
                self.loadingIndicatorImageName = "freespoke_loader_torch_dark"
                let closeImage = UIImage(named: "img_close_onboarding")?.withTintColor(.whiteColor, renderingMode: .alwaysOriginal)
                self.btnClose.setImage(closeImage, for: .normal)
            case .light:
                self.view.backgroundColor = UIColor.gray7
                self.topBackgroundView.backgroundColor = UIColor.gray7
                self.webView.backgroundColor = UIColor.white // UIColor.gray7
                self.webView.scrollView.backgroundColor = UIColor.gray7 // UIColor.gray7
                self.loadingIndicatorImageName = "freespoke_loader_torch_light"
                let closeImage = UIImage(named: "img_close_onboarding")?.withTintColor(.blackColor, renderingMode: .alwaysOriginal)
                self.btnClose.setImage(closeImage, for: .normal)
            }
        }
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willResignActiveHandler),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    @objc private func willResignActiveHandler() {
        self.shouldAutoClose = true
    }
    
    @objc private func applicationDidBecomeActive() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            guard let self = self else { return }
            if self.shouldAutoClose {
                self.motionDismissViewController()
            }
        })
    }
    
    private func prepareUI() {
        self.applyTheme()
    }
    
    private func addingViews() {
        switch self.source {
        case .signInWithApple,
                .generalLogin:
            self.view.addSubview(self.webView)
        case .accountPage:
            self.view.addSubview(self.webView)
            self.addCloseButton()
        }
    }
    
    private func setupConstraints() {
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        switch self.source {
        case .signInWithApple,
                .generalLogin:
            self.webView.pinToView(view: self.view, safeAreaLayout: true, withInsets: UIEdgeInsets(equalInset: 0))
        case .accountPage:
            NSLayoutConstraint.activate([
                self.webView.topAnchor.constraint(equalTo: self.btnClose.bottomAnchor, constant: 0),
                self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
            ])
        }
    }
    
    func startLoadingWebView(url: URL?) {
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
            self.startIndicatorIfNeeded()
        }
    }
    
    private func startIndicatorIfNeeded() {
        guard self.activityIndicatorEnabled else { return }
        
        let gifImage = UIImage.gifImageWithName(self.loadingIndicatorImageName)
        self.loadingIndicatorView = UIImageView(image: gifImage)
        
        guard let loadingIndicatorView = self.loadingIndicatorView else { return }
        guard loadingIndicatorView.superview == nil else { return }
        
        self.view.addSubview(loadingIndicatorView)
        
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -100),
            loadingIndicatorView.heightAnchor.constraint(equalToConstant: 160),
            loadingIndicatorView.widthAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    private func stopIndicator() {
        self.loadingIndicatorView?.removeFromSuperview()
        self.loadingIndicatorView = nil
    }
    
    private func handleCallbackUrl(callBackUrl: URL) {
        if let request = self.authorizationRequest {
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
        } else {
            print("TEST: callBackUrl: ", callBackUrl)
        }
    }
}

extension OAuthLoginVC: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.shouldAutoClose = false
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        let loginCallBackUrl = "\(url.scheme ?? ""):\(url.relativePath)"
        
        if loginCallBackUrl == OAuthConstants.callBackURLOAuthLogin {
            self.handleCallbackUrl(callBackUrl: url)
            decisionHandler(.cancel)
        } else {
            webView.customUserAgent = UserAgent.getUserAgent(domain: url.baseDomain ?? "")
            UserScriptManager.shared.injectFreespokeDomainRequiredInfoScriptsIfNeeded(self.tabManager.selectedTab)
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.stopIndicator()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("TEST: We had error: \(error)")
    }
}

extension OAuthLoginVC {
    private func addCloseAction() {
        self.btnClose.addTarget(self,
                                action: #selector(self.btnCloseTapped),
                                for: .touchUpInside)
    }
    
    @objc private func btnCloseTapped() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.motionDismissViewController()
        }
    }
}

// MARK: - Feespoke account events Delegates

extension OAuthLoginVC: FreespokeAuthEventLoginHelperDelegate {
    func freespokeAuthEventLoginHelper(_ helper: FreespokeAuthEventLoginHelper, userLoggedInForTab tab: Tab) { }
}

extension OAuthLoginVC: FreespokeAuthEventLogoutHelperDelegate {
    func freespokeAuthEventLogoutHelper(_ helper: FreespokeAuthEventLogoutHelper, userLoggedOutForTab tab: Tab) {
        self.motionDismissViewController()
    }
}

extension OAuthLoginVC: FreespokeAuthEventAccountUpdatedHelperDelegate {
    func freespokeAuthEventAccountUpdatedHelper(_ helper: FreespokeAuthEventAccountUpdatedHelper, userAccountUpdatedInTab tab: Tab) { }
}

extension OAuthLoginVC: FreespokeAuthEventDeactivateAccountHelperDelegate {
    func freespokeAuthEventDeactivateAccountHelper(_ helper: FreespokeAuthEventDeactivateAccountHelper, userAccountDeactivatedForTab tab: Tab) {
        self.motionDismissViewController()
    }
}
