// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import WebKit

class UserScriptManager {
    // Scripts can use this to verify the *app* (not JS on the web) is calling into them.
    public static let appIdToken = UUID().uuidString
    
    // Singleton instance.
    public static let shared = UserScriptManager()
    
    private let compiledUserScripts: [String: WKUserScript]
    
    private let noImageModeUserScript = WKUserScript.createInDefaultContentWorld(
        source: "window.__firefox__.NoImageMode.setEnabled(true)",
        injectionTime: .atDocumentStart,
        forMainFrameOnly: true)
    /*
     //    private let nightModeUserScript = WKUserScript.createInDefaultContentWorld(
     //        source: "window.__firefox__.NightMode.setEnabled(true)",
     //        injectionTime: .atDocumentStart,
     //        forMainFrameOnly: true)
     */
    
    private let printHelperUserScript = WKUserScript.createInPageContentWorld(
        source: "window.print = function () { window.webkit.messageHandlers.printHandler.postMessage({}) }",
        injectionTime: .atDocumentEnd,
        forMainFrameOnly: false)
    
    private init() {
        var compiledUserScripts: [String: WKUserScript] = [:]
        
        // Cache all of the pre-compiled user scripts so they don't
        // need re-fetched from disk for each webview.
        [(WKUserScriptInjectionTime.atDocumentStart, mainFrameOnly: false),
         (WKUserScriptInjectionTime.atDocumentEnd, mainFrameOnly: false),
         (WKUserScriptInjectionTime.atDocumentStart, mainFrameOnly: true),
         (WKUserScriptInjectionTime.atDocumentEnd, mainFrameOnly: true)].forEach { arg in
            let (injectionTime, mainFrameOnly) = arg
            let name = (mainFrameOnly ? "MainFrame" : "AllFrames") + "AtDocument" + (injectionTime == .atDocumentStart ? "Start" : "End")
            if let path = Bundle.main.path(forResource: name, ofType: "js"),
               let source = try? NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String {
                let wrappedSource = "(function() { const APP_ID_TOKEN = '\(UserScriptManager.appIdToken)'; \(source) })()"
                let userScript = WKUserScript.createInDefaultContentWorld(source: wrappedSource, injectionTime: injectionTime, forMainFrameOnly: mainFrameOnly)
                compiledUserScripts[name] = userScript
            }
            let webcompatName = "Webcompat\(name)"
            if let webCompatPath = Bundle.main.path(forResource: webcompatName, ofType: "js"),
               let source = try? NSString(contentsOfFile: webCompatPath, encoding: String.Encoding.utf8.rawValue) as String {
                let wrappedSource = "(function() { const APP_ID_TOKEN = '\(UserScriptManager.appIdToken)'; \(source) })()"
                let userScript = WKUserScript.createInPageContentWorld(source: wrappedSource, injectionTime: injectionTime, forMainFrameOnly: mainFrameOnly)
                compiledUserScripts[webcompatName] = userScript
            }
        }
        
        self.compiledUserScripts = compiledUserScripts
    }
    
    public func injectUserScriptsIntoTab(_ tab: Tab, nightMode: Bool, noImageMode: Bool) {
        // Start off by ensuring that any previously-added user scripts are
        // removed to prevent the same script from being injected twice.
        tab.webView?.configuration.userContentController.removeAllUserScripts()
        
        // Inject all pre-compiled user scripts.
        [(WKUserScriptInjectionTime.atDocumentStart, mainFrameOnly: false),
         (WKUserScriptInjectionTime.atDocumentEnd, mainFrameOnly: false),
         (WKUserScriptInjectionTime.atDocumentStart, mainFrameOnly: true),
         (WKUserScriptInjectionTime.atDocumentEnd, mainFrameOnly: true)].forEach { arg in
            let (injectionTime, mainFrameOnly) = arg
            let name = (mainFrameOnly ? "MainFrame" : "AllFrames") + "AtDocument" + (injectionTime == .atDocumentStart ? "Start" : "End")
            if let userScript = compiledUserScripts[name] {
                tab.webView?.configuration.userContentController.addUserScript(userScript)
            }
            let webcompatName = "Webcompat\(name)"
            if let webcompatUserScript = compiledUserScripts[webcompatName] {
                tab.webView?.configuration.userContentController.addUserScript(webcompatUserScript)
            }
        }
        // Inject the Print Helper. This needs to be in the `page` content world in order to hook `window.print()`.
        tab.webView?.configuration.userContentController.addUserScript(printHelperUserScript)
        // If Night Mode is enabled, inject a small user script to ensure
        // that it gets enabled immediately when the DOM loads.
        
        /* Disabled nightMode script
         
         //        if nightMode {
         //            tab.webView?.configuration.userContentController.addUserScript(nightModeUserScript)
         //        }
         */
        //        else {
        //            tab.webView?.configuration.userContentController.addUserScript(lightModeUserScript)
        //        }
        // If No Image Mode is enabled, inject a small user script to ensure
        // that it gets enabled immediately when the DOM loads.
        if noImageMode {
            tab.webView?.configuration.userContentController.addUserScript(noImageModeUserScript)
        }
    }
}

// MARK: - Freespoke User Scripts

extension UserScriptManager {
    private func removeFreespokeUserScriptThatContains(scriptName: String, userContentController: WKUserContentController) {
        DispatchQueue.main.async {
            var allUserScripts = userContentController.userScripts
            
            // Filter out the user scripts containing "__freespoke__" from the array
            allUserScripts = allUserScripts.filter { !$0.source.contains("\(scriptName)") }
            
            // Reset the userScripts property with the filtered array
            userContentController.removeAllUserScripts()
            allUserScripts.forEach { userContentController.addUserScript($0) }
        }
    }
    
    private func addedScriptsContainName(scriptName: String, userContentController: WKUserContentController) -> (contains: Bool, wholeSource: String?) {
        let allUserScripts = userContentController.userScripts
        let similarScripts = allUserScripts.filter { $0.source.contains(scriptName) }
        return (similarScripts.first != nil, similarScripts.first?.source)
    }
    
    // MARK: Freespoke domain user scripts
    
    public func injectFreespokeDomainRequiredInfoScriptsIfNeeded(_ tab: Tab?) {
        guard let tab = tab else { return }
        guard let userContentController = tab.webView?.configuration.userContentController else { return }
        
        let setFreespokeObjectIdentifier = "// iosIdentifier = set__freespoke__object" // It is required to start from "//"
        let passFreespokeAccessTokenIdentifier = "// iosIdentifier = js_pass__freespoke__AccessToken" // It is required to start from "//"
        let passFreespokeRefreshTokenIdentifier = "// iosIdentifier = js_pass__freespoke__RefreshToken" // It is required to start from "//"
        let passHasPremiumIdentifier = "// iosIdentifier = js_pass__freespoke__HasPremium" // It is required to start from "//"
        
        let allIdentifiers = [setFreespokeObjectIdentifier, passFreespokeAccessTokenIdentifier, passFreespokeRefreshTokenIdentifier, passHasPremiumIdentifier]
        
        guard tab.url?.isFreespokeDomain() == true else {
            allIdentifiers.forEach({ self.removeFreespokeUserScriptThatContains(scriptName: $0, userContentController: userContentController) })
            return
        }
        
        // MARK: Set __frespoke__ object using Java Script code
        let setFreespokeObjectJsCode = """
            \(setFreespokeObjectIdentifier)
            (function() {
                // Define window.__freespoke__ if not already defined
                if (!window.__freespoke__) {
                    window.__freespoke__ = {};
                }
            })();
        """
        
        let setFreespokeObjectScript = WKUserScript(
            source: setFreespokeObjectJsCode,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        
        let containsResult = self.addedScriptsContainName(scriptName: setFreespokeObjectIdentifier,
                                                          userContentController: userContentController)
        
        if !containsResult.contains {
            userContentController.addUserScript(setFreespokeObjectScript)
        }
        
        // MARK: Pass AccessToken using Java Script code
        if let accessToken = Keychain.authInfo?.accessToken {
            let newSource =  """
            \(passFreespokeAccessTokenIdentifier)
            (function() {
                window.__freespoke__.AccessToken = '\(accessToken)';
            })();
        """
            
            let accessTokenUserScript: WKUserScript = WKUserScript(
                source: newSource,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true)
            
            let containsResult = self.addedScriptsContainName(scriptName: passFreespokeAccessTokenIdentifier,
                                                              userContentController: userContentController)
            
            if containsResult.contains {
                if containsResult.wholeSource != newSource {
                    self.removeFreespokeUserScriptThatContains(scriptName: passFreespokeAccessTokenIdentifier,
                                                               userContentController: userContentController)
                    tab.webView?.configuration.userContentController.addUserScript(accessTokenUserScript)
                }
            } else {
                tab.webView?.configuration.userContentController.addUserScript(accessTokenUserScript)
            }
        }
        
        // MARK: Pass RefreshToken using Java Script code
        if let refreshToken = Keychain.authInfo?.refreshToken {
            let newSource = """
            \(passFreespokeRefreshTokenIdentifier)
            (function() {
                window.__freespoke__.RefreshToken = '\(refreshToken)';
            })();
        """
            
            let refreshTokenUserScript: WKUserScript = WKUserScript(
                source: newSource,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true)
            
            let containsResult = self.addedScriptsContainName(scriptName: passFreespokeRefreshTokenIdentifier,
                                                              userContentController: userContentController)
            
            if containsResult.contains {
                if containsResult.wholeSource != newSource {
                    self.removeFreespokeUserScriptThatContains(scriptName: passFreespokeRefreshTokenIdentifier,
                                                               userContentController: userContentController)
                    tab.webView?.configuration.userContentController.addUserScript(refreshTokenUserScript)
                }
            } else {
                tab.webView?.configuration.userContentController.addUserScript(refreshTokenUserScript)
            }
        }
        
        // MARK: Pass HasPremium using Java Script code
        self.checkIsUserHasPremium(isPremiumCompletion: { isPremium in
            ensureMainThread {
                let newSource = """
                \(passHasPremiumIdentifier)
                (function() {
                    window.__freespoke__.HasPremium = '\(isPremium)';
                })();
            """
                
                let hasPremiumUserScript: WKUserScript = WKUserScript(
                    source: newSource,
                    injectionTime: .atDocumentStart,
                    forMainFrameOnly: true)
                
                let containsResult = self.addedScriptsContainName(scriptName: passHasPremiumIdentifier,
                                                                  userContentController: userContentController)
                
                if containsResult.contains {
                    if containsResult.wholeSource != newSource {
                        self.removeFreespokeUserScriptThatContains(scriptName: passHasPremiumIdentifier,
                                                                   userContentController: userContentController)
                        tab.webView?.configuration.userContentController.addUserScript(hasPremiumUserScript)
                    }
                } else {
                    tab.webView?.configuration.userContentController.addUserScript(hasPremiumUserScript)
                }
            }
        })
    }
    
    private func checkIsUserHasPremium(isPremiumCompletion: ((_ isPremium: Bool) -> Void)?) {
        Task {
            do {
                if let userType = try? await AppSessionManager.shared.userType() {
                    switch userType {
                    case .authorizedWithoutPremium:
                        isPremiumCompletion?(false)
                    case .premium, .premiumBecauseAppleAccountHasSubscription:
                        isPremiumCompletion?(true)
                    case .unauthorized:
                        isPremiumCompletion?(false)
                    }
                }
            }
        }
    }
}
