// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

extension Tab {
    func prepareBlocker() {
        // MARK: For ad blocker
        NotificationCenter.default.addObserver(self, selector: #selector(adBlockChanged), name: Notification.Name.adBlockSettingsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldDisableAdBlockerFor(_:)), name: Notification.Name.disableAdBlockerForCurrentDomain, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldEnableAdBlockerFor(_:)), name: Notification.Name.enableAdBlockerForCurrentDomain, object: nil)

        self.loadAdBlocking { [weak self] in
//            DispatchQueue.main.sync { [weak self] in
//                guard let webView = self?.webView else { return }
//                if self?.webView?.url == nil {
//                    let _ = self?.webView?.load(URLRequest(url: URL(string: "https://localhost:8080")!))
//                }
//            }
        }
    }
    
    func loadAdBlocking(completion: @escaping (() -> Void)) {
        Task {
            if let shouldBlockAds = try? await AdBlockManager.shared.shouldBlockAds(), shouldBlockAds {
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
    }
    
    @MainActor
    @objc func adBlockChanged() {
        guard let webView = self.webView else { return }
        guard let url = webView.url else { return }
        let currentRequest = URLRequest(url: url)
        Task {
            if let shouldBlockAds = try? await AdBlockManager.shared.shouldBlockAds(), shouldBlockAds {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadAdBlocking {
                        webView.load(currentRequest)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    AdBlockManager.shared.disableAdBlock(forWebView: webView)
                    webView.load(currentRequest)
                }
            }
        }
    }
    
    @objc private func shouldDisableAdBlockerFor(_ notification: NSNotification) {
        guard let webView = self.webView else { return }
        guard let hostForBlocking = notification.userInfo?[NotificationKeyNameForValue.host.rawValue] as? String else { return }
        
        let domains: [String] = (UserDefaults.standard.object(forKey: SettingsKeys.domains) as? [String]) ?? []
        if let url = webView.url, let currentHost = url.host {
            guard hostForBlocking == currentHost else { return }
            let isContainsDomain = domains.contains(where: { $0 == currentHost })
            AdBlockManager.shared.shouldAddBlockRuleList(isShouldAddBlockList: !isContainsDomain, forWebView: webView)
            let currentRequest = URLRequest(url: webView.url!)
            webView.load(currentRequest)
        }
    }
    
    @objc private func shouldEnableAdBlockerFor(_ notification: NSNotification) {
        guard let webView = self.webView else { return }
        guard let hostForBlocking = notification.userInfo?[NotificationKeyNameForValue.host.rawValue] as? String else { return }
        
        let domains: [String] = (UserDefaults.standard.object(forKey: SettingsKeys.domains) as? [String]) ?? []
        if let url = webView.url, let currentHost = url.host {
            guard hostForBlocking == currentHost else { return }
            let isContainsDomain = domains.contains(where: { $0 == currentHost })
            AdBlockManager.shared.shouldAddBlockRuleList(isShouldAddBlockList: !isContainsDomain, forWebView: webView)
            let currentRequest = URLRequest(url: webView.url!)
            webView.load(currentRequest)
        }
    }

}
