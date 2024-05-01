// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import WebKit

protocol FreespokeAuthEventLogoutHelperDelegate: AnyObject {
    func freespokeAuthEventLogoutHelper(_ helper: FreespokeAuthEventLogoutHelper, userLoggedOutForTab tab: Tab)
}

class FreespokeAuthEventLogoutHelper: TabContentScript {
    weak var delegate: FreespokeAuthEventLogoutHelperDelegate?
    fileprivate weak var tab: Tab?
    
    required init(tab: Tab) {
        self.tab = tab
    }
    
    func scriptMessageHandlerName() -> String? {
        return "AuthEventLogout"
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        guard let tab = tab else { return }
        AppSessionManager.shared.webWrapperEventUserLoggedOut()
        DispatchQueue.main.async {
            self.delegate?.freespokeAuthEventLogoutHelper(self, userLoggedOutForTab: tab)
        }
    }
    
    class func name() -> String {
        return "AuthEventLogout"
    }
}
