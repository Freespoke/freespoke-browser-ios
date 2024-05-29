// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import WebKit

protocol FreespokeAuthEventDeactivateAccountHelperDelegate: AnyObject {
    func freespokeAuthEventDeactivateAccountHelper(_ helper: FreespokeAuthEventDeactivateAccountHelper, userAccountDeactivatedForTab tab: Tab)
}

class FreespokeAuthEventDeactivateAccountHelper: TabContentScript {
    weak var delegate: FreespokeAuthEventDeactivateAccountHelperDelegate?
    fileprivate weak var tab: Tab?
    
    required init(tab: Tab) {
        self.tab = tab
    }
    
    func scriptMessageHandlerName() -> String? {
        return "AuthEventDeactivateAccount"
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        guard let tab = tab else { return }
        AppSessionManager.shared.webWrapperEventUserDeactivatedAccount()
        DispatchQueue.main.async {
            self.delegate?.freespokeAuthEventDeactivateAccountHelper(self, userAccountDeactivatedForTab: tab)
        }
    }
    
    class func name() -> String {
        return "AuthEventDeactivateAccount"
    }
}
