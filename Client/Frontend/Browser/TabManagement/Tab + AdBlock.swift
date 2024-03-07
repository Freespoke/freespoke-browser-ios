// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

extension Tab {
    
    func prepareBlocker() {
        // MARK: For ad blocker
        NotificationCenter.default.addObserver(self, selector: #selector(adBlockChanged), name: NSNotification.Name.adBlockSettingsChanged, object: nil)
        self.loadAdBlocking { [weak self] in
            if self?.webView?.url == nil {
                let _ = self?.webView?.load(URLRequest(url: URL(string: "http://localhost:8080")!))
            }
        }
    }
    
    func loadAdBlocking(completion: @escaping (() -> ())) {
        if #available(iOS 11.0, *), AdBlockManager.shared.shouldBlockAds() {
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
        guard #available(iOS 11.0, *) else { return }
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
    
}
