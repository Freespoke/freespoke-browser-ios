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
