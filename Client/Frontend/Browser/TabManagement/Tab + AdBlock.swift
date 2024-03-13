// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

extension Tab {
    
    func prepareBlocker() {
        // MARK: For ad blocker
        NotificationCenter.default.addObserver(self, selector: #selector(adBlockChanged), name: Notification.Name.adBlockSettingsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldDisableAdBlockerFor), name: Notification.Name.disableAdBlockerForCurrentDomain, object: nil)
        self.loadAdBlocking { [weak self] in
            if self?.webView?.url == nil {
                let _ = self?.webView?.load(URLRequest(url: URL(string: "http://localhost:8080")!))
            }
        }
    }
    
    func loadAdBlocking(completion: @escaping (() -> ())) {
        if AdBlockManager.shared.shouldBlockAds() {
            let group = DispatchGroup()
            
            for hostFile in HostFileNames.allValues {
                group.enter()
                AdBlockManager.shared.setupAdBlock(forKey: hostFile.rawValue, filename: hostFile.rawValue, webView: webView) {
                    group.leave()
                }
            }
            
            group.enter()
            AdBlockManager.shared.setupAdBlockFromStringLiteral(forWebView: self.webView) {
                group.leave()
            }
            
            group.notify(queue: .main, execute: {
                completion()
            })
        } else {
            completion()
        }
    }
    
    @objc func adBlockChanged() {
        guard let webView = self.webView else { return }
        let currentRequest = URLRequest(url: webView.url!)
        if AdBlockManager.shared.shouldBlockAds() {
            loadAdBlocking {
                webView.load(currentRequest)
            }
        } else {
            AdBlockManager.shared.disableAdBlock(forWebView: webView)
            webView.load(currentRequest)
        }
    }
    
    @objc private func shouldDisableAdBlockerFor() {
        guard let webView = self.webView else { return }
        let domains: [String] = (UserDefaults.standard.object(forKey: SettingsKeys.domains) as? [String]) ?? []
        if let url = webView.url, let domain = url.host {
            let isContainsDomain = domains.contains(where: { $0 == domain })
            AdBlockManager.shared.shouldAddBlockRuleList(isShouldAddBlockList: !isContainsDomain, forWebView: webView)
        } else {
            AdBlockManager.shared.shouldAddBlockRuleList(isShouldAddBlockList: true, forWebView: webView)
        }
        let currentRequest = URLRequest(url: webView.url!)
        webView.load(currentRequest)
    }
    
}
