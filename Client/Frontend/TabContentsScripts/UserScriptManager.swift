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
        
        let script = """
        const elements = [
          ".ad-300x600",
          ".ad-458x80",
          ".ad-bottom",
          ".ad-column",
          ".ad-manager/$~stylesheet",
          ".ad-right",
          ".ad-sidebar",
          ".ad-unit",
          ".ad-util",
          ".ad.jpg.pagespeed",
          ".ad.jpg?",
          ".adbanner",
          ".ads-banner"
        ];

        for (const element of elements) {
          const els = document.querySelectorAll(element);
          for (const el of els) {
            el.parentNode.removeChild(el);
          }
        }
        """
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        tab.webView?.configuration.userContentController.addUserScript(userScript)
        
    }
}

// MARK: - Freespoke User Scripts

extension UserScriptManager {
    // MARK: Freespoke domain user scripts
    func injectFreespokeDomainRequiredInfoScriptsIfNeeded(webView: WKWebView, navigationAction: WKNavigationAction) {
        guard let url = navigationAction.request.url, url.isFreespokeDomain() else {
            return
        }
        
        // MARK: Set __frespoke__ object using Java Script code
        let setFreespokeObjectJsCode = """
            (function() {
                // Define window.__freespoke__ if not already defined
                if (!window.__freespoke__) {
                    window.__freespoke__ = {};
                }
            })();
        """
        
        webView.evaluateJavaScript(setFreespokeObjectJsCode)
        
        // MARK: Pass AccessToken using Java Script code
        if let accessToken = Keychain.authInfo?.accessToken {
            let setAccessTokenJsCode =  """
            (function() {
                window.__freespoke__.AccessToken = '\(accessToken)';
            })();
        """
            
            webView.evaluateJavaScript(setAccessTokenJsCode)
        }
        
        // MARK: Pass RefreshToken using Java Script code
        if let refreshToken = Keychain.authInfo?.refreshToken {
            let setRefreshTokenJsCode = """
            (function() {
                window.__freespoke__.RefreshToken = '\(refreshToken)';
            })();
        """
            
            webView.evaluateJavaScript(setRefreshTokenJsCode)
        }
        
        // MARK: Pass HasPremium using Java Script code
        AppSessionManager.shared.checkIsUserHasPremium(isPremiumCompletion: { isPremium in
            ensureMainThread {
                let setHasPremiumJsCode = """
                (function() {
                    window.__freespoke__.HasPremium = '\(isPremium)';
                })();
            """
                
                webView.evaluateJavaScript(setHasPremiumJsCode)
            }
        })
    }
}
