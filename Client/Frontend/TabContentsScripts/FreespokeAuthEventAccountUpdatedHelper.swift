// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import WebKit

protocol FreespokeAuthEventAccountUpdatedHelperDelegate: AnyObject {
    func freespokeAuthEventAccountUpdatedHelper(_ helper: FreespokeAuthEventAccountUpdatedHelper, userAccountUpdatedInTab tab: Tab)
}

class FreespokeAuthEventAccountUpdatedHelper: TabContentScript {
    weak var delegate: FreespokeAuthEventAccountUpdatedHelperDelegate?
    fileprivate weak var tab: Tab?
    
    required init(tab: Tab) {
        self.tab = tab
    }
    
    func scriptMessageHandlerName() -> String? {
        return "AuthEventAccountUpdated"
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        guard let tab = tab else { return }
        AppSessionManager.shared.webWrapperEventUserAccountUpdated()
        DispatchQueue.main.async {
            self.delegate?.freespokeAuthEventAccountUpdatedHelper(self, userAccountUpdatedInTab: tab)
        }
    }
    
    class func name() -> String {
        return "AuthEventAccountUpdated"
    }
}
