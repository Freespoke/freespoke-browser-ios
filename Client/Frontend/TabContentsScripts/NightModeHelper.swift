// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Foundation
import WebKit
import Shared

class NightModeHelper: TabContentScript {
    fileprivate weak var tab: Tab?
    
    required init(tab: Tab) {
        self.tab = tab
    }
    
    static func name() -> String {
        return "NightMode"
    }
    
    func scriptMessageHandlerName() -> String? {
        return "NightMode"
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        // Do nothing.
    }
    
    static func hasEnabledDarkTheme() -> Bool {
//        LegacyThemeManager.instance.currentName == .dark
        let theme = BuiltinThemeName(rawValue: LegacyThemeManager.instance.current.name) ?? .normal
        let isNightMode = (theme == .dark) ? true : false
        return isNightMode
    }
    
    static func checkIsWebPageSupportDarkModeStyle(webView: WKWebView, completion: @escaping((_ supportsDarkMode: Bool?) -> Void)) {
        // Evaluate JavaScript to check for dark mode support
        let jsCode = """
                   (() => {
                       const stylesheets = document.styleSheets;
                       for (let i = 0; i < stylesheets.length; i++) {
                           const stylesheet = stylesheets[i];
                           const media = stylesheet.media;
                           if (media && media.length > 0) {
                               for (let j = 0; j < media.length; j++) {
                                   if (media[j] === '(prefers-color-scheme: dark)') {
                                       return true;
                                   }
                               }
                           }
                       }
                       return false;
                   })();
               """
        
        webView.evaluateJavaScript(jsCode) { (result, error) in
            if let error = error {
                print("DEBUG: Error evaluating JavaScript: \(error)")
                completion(nil)
                return
            }
            
            guard let supportsDarkMode = result as? Bool else {
                print("DEBUG: Invalid result type")
                completion(nil)
                return
            }
            
            if supportsDarkMode {
                print("DEBUG: Web page supports dark mode styles")
                completion(true)
            } else {
                print("DEBUG: Web page does not support dark mode styles")
                completion(false)
            }
        }
    }
    
    static func changeUserInterfaceStyle(to themeType: ThemeType, themeManager: ThemeManager) {
        LegacyThemeManager.instance.systemThemeIsOn = false
        themeManager.setSystemTheme(isOn: false)
        switch themeType {
        case .light:
            LegacyThemeManager.instance.current = LegacyNormalTheme()
            themeManager.changeCurrentTheme(.light)
        case .dark:
            LegacyThemeManager.instance.current = LegacyDarkTheme()
            themeManager.changeCurrentTheme(.dark)
        }
        print("TEST: NightModeHelper changeUserInterfaceStyle to theme: ", themeType)
    }
}
