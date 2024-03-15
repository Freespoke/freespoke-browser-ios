

import Foundation
import WebKit

class AdBlockManager {
    static let shared = AdBlockManager()
    
    var ruleLists: [WKContentRuleList] = []
    
    func setupAdBlock(forKey key: String, filename: String, webView: WKWebView?, completion: (() -> Void)?) {
        if UserDefaults.standard.bool(forKey: key) {
            WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: key) { [weak self] ruleList, error in
                if let error = error {
                    print("\(filename).json" + error.localizedDescription)
                    UserDefaults.standard.set(false, forKey: key)
                    self?.setupAdBlock(forKey: key, filename: filename, webView: webView, completion: completion)
                    return
                }
                if let list = ruleList {
                    self?.ruleLists.append(list)
                    webView?.configuration.userContentController.add(list)
                    completion?()
                }
            }
        } else {
            if let jsonPath = Bundle.main.path(forResource: filename, ofType: "json"), let jsonContent = try? String(contentsOfFile: jsonPath, encoding: .utf8) {
                WKContentRuleListStore.default().compileContentRuleList(forIdentifier: key, encodedContentRuleList: jsonContent) { [weak self] ruleList, error in
                    if let error = error {
                        print("\(filename).json" + error.localizedDescription)
                        completion?()
                        return
                    }
                    if let list = ruleList {
                        self?.ruleLists.append(list)
                        webView?.configuration.userContentController.add(list)
                        UserDefaults.standard.set(true, forKey: key)
                        completion?()
                    }
                }
            }
        }
    }
    
    func setupAdBlockFromStringLiteral(forWebView webView: WKWebView?, completion: (() -> Void)?) {
        // Swift 4  Multi-line string literals
        let jsonString = """
[{
  "trigger": {
    "url-filter": "://googleads\\\\.g\\\\.doubleclick\\\\.net.*"
  },
  "action": {
    "type": "block"
  }
}]
"""
        if UserDefaults.standard.bool(forKey: SettingsKeys.stringLiteralAdBlock) {
            // list should already be compiled
            WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: SettingsKeys.stringLiteralAdBlock) { [weak self] (contentRuleList, error) in
                if let error = error {
                    print(error.localizedDescription)
                    UserDefaults.standard.set(false, forKey: SettingsKeys.stringLiteralAdBlock)
                    self?.setupAdBlockFromStringLiteral(forWebView: webView, completion: completion)
                    return
                }
                if let list = contentRuleList {
                    self?.ruleLists.append(list)
                    webView?.configuration.userContentController.add(list)
                    completion?()
                }
            }
        } else {
            WKContentRuleListStore.default().compileContentRuleList(forIdentifier: SettingsKeys.stringLiteralAdBlock, encodedContentRuleList: jsonString) { [weak self] contentRuleList, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion?()
                    return
                }
                if let list = contentRuleList {
                    self?.ruleLists.append(list)
                    webView?.configuration.userContentController.add(list)
                    UserDefaults.standard.set(true, forKey: SettingsKeys.stringLiteralAdBlock)
                    completion?()
                }
            }
        }
    }
    
    func shouldAddBlockRuleList(isShouldAddBlockList: Bool, forWebView webView: WKWebView?) {
        switch isShouldAddBlockList {
        case true:
            for list in ruleLists {
                webView?.configuration.userContentController.add(list)
            }
        case false:
            webView?.configuration.userContentController.removeAllContentRuleLists()
        }
    }
    
    func shouldBlockAds() -> Bool {
        return AppSessionManager.shared.userType == .premium
//        return true
    }
    
    func disableAdBlock(forWebView webView: WKWebView?) {
        self.ruleLists = []
        webView?.configuration.userContentController.removeAllContentRuleLists()
    }
}