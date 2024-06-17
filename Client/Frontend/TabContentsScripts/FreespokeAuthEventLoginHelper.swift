// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import WebKit

protocol FreespokeAuthEventLoginHelperDelegate: AnyObject {
    func freespokeAuthEventLoginHelper(_ helper: FreespokeAuthEventLoginHelper, userLoggedInForTab tab: Tab)
}

class FreespokeAuthEventLoginHelper: TabContentScript {
    weak var delegate: FreespokeAuthEventLoginHelperDelegate?
    fileprivate weak var tab: Tab?
    
    required init(tab: Tab) {
        self.tab = tab
    }
    
    func scriptMessageHandlerName() -> String? {
        return "AuthEventLogin"
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        guard let tab = tab else { return }
        guard let body = message.body as? [String: Any] else { return }
        guard let accessToken = body["access_token"] as? String else { return }
        guard let idToken = body["id_token"] as? String else { return }
        guard let refreshToken = body["refresh_token"] as? String else { return }
        
        let authInfo = FreespokeAuthModel(idToken: idToken,
                                          accessToken: accessToken,
                                          refreshToken: refreshToken,
                                          magicLink: nil)
        AppSessionManager.shared.webWrapperEventUserLoggedIn(authInfo: authInfo)
        DispatchQueue.main.async {
            self.delegate?.freespokeAuthEventLoginHelper(self, userLoggedInForTab: tab)
        }
    }
    
    class func name() -> String {
        return "AuthEventLogin"
    }
}
