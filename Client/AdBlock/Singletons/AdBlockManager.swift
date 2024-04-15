

import Foundation
import WebKit
import Jam

// MARK: Assumed that all easyLists are in .txt format

enum EasyListsName: String {
    case easyList = "easy-list"
    case easyListJson = "easyList"
    case easyPrivacyList = "easy-privacy"
    case easyFanboyAnnoyance = "fanboy-annoyance"
    static var names: [EasyListsName] = [.easyList]
    static var testNames: [EasyListsName] = [.easyListJson]
    
    var url: URL? {
        switch self {
        case .easyList:
            return URL(string: Constants.EasyListsURL.easyList)
        case .easyPrivacyList:
            return URL(string: Constants.EasyListsURL.easyPrivacyList)
        case .easyFanboyAnnoyance:
            return URL(string: Constants.EasyListsURL.easyFanboyAnnoyance)
        case .easyListJson:
            return nil
        }
    }

}

class AdBlockManager {
    static let shared = AdBlockManager()
    
    let parser = RuleParser()
    let sut = WebKitRuleGenerator()
        
    enum SaveWhitelistActionStatus {
        case saved
        case alreadyContains
    }
    
    var ruleLists: [WKContentRuleList] = []
    
    let easyListUpdateTimeInterval: Double = 60 * 60 * 24
        
    func setupAdBlockInternalRuleLists(webView: WKWebView?, completion: (() -> Void)?) {
        guard ruleLists.isEmpty else { completion?(); return }
        let group = DispatchGroup()
        for name in EasyListsName.names {
            group.enter()
            self.preparingInternalRuleList(webView: webView, filename: name, completion: {
                group.leave()
            })
        }
        
        let name: EasyListsName = .easyListJson
        group.enter()
        self.setupAdBlock(forKey: name.rawValue, filename: name.rawValue, webView: webView, completion: {
            group.leave()
        })
        
        group.notify(queue: .main, execute: {
            completion?()
        })
    }
    
    private func preparingInternalRuleList(webView: WKWebView?, filename: EasyListsName, completion: (() -> Void)?) {
        switch UserDefaults.standard.bool(forKey: filename.rawValue) {
        case true:
            WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: filename.rawValue) { [weak self] ruleList, error in
                if let error = error {
                    print("\(filename).json" + error.localizedDescription)
                    UserDefaults.standard.set(false, forKey: filename.rawValue)
                    self?.preparingInternalRuleList(webView: webView, filename: filename, completion: completion)
                    return
                }
                if let list = ruleList {
                    self?.ruleLists.append(list)
                    webView?.configuration.userContentController.add(list)
                    completion?()
                }
            }
        case false:
            Task { @MainActor [weak self] in
                var path: String? = Bundle.main.path(forResource: filename.rawValue, ofType: "txt")
                if let pathFromDocumentDirectory = EasyListsStorage.shared.readFileFromDocuments(filename: filename) {
                    print("added list from document directory: \(pathFromDocumentDirectory)")
                    print("currentTime create url: \(Date().description)")
                    path = pathFromDocumentDirectory.path
                } else {
                    print("can not create pathFromDocumentDirectory")
                }
                guard let path = path else { return }
                if let jsonContent = try await self?.prepareEasyListRulesJSON(path: path) {
                    DispatchQueue.main.async { [weak self] in
                        print("currentTime will start: \(Date().description)")
                        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: filename.rawValue, encodedContentRuleList: jsonContent) { [weak self] ruleList, error in
                            if let error = error {
                                print("\(filename).json" + error.localizedDescription)
                                completion?()
                                print("currentTime end with error: \(Date().description)")
                                return
                            }
                            if let list = ruleList {
                                self?.ruleLists.append(list)
                                webView?.configuration.userContentController.add(list)
                                
                                UserDefaults.standard.set(true, forKey: filename.rawValue)
                                completion?()
                                guard let url = webView?.url else { return }
                                print("currentTime end ss: \(Date().description)")
                                webView?.load(URLRequest(url: url))
                            }
                        }
                    }
                }
            }
        }
    }
    
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
    
    private func prepareEasyListRulesJSON(path: String) async throws -> String? {
        let rules = await parser.parse(file: path)
        let output = sut.generate(for: rules)
        guard let jsonData = try? JSONSerialization.data(withJSONObject: output) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
    
    func shouldAddBlockRuleList(isShouldAddBlockList: Bool, forWebView webView: WKWebView?, request: URLRequest? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch isShouldAddBlockList {
            case true:
                for list in self.ruleLists {
                    print("list was added: \(String(describing: list.identifier))")
                    webView?.configuration.userContentController.add(list)
                }
            case false:
                webView?.configuration.userContentController.removeAllContentRuleLists()
            }
            if let request = request {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    webView?.load(request)
                })
            }
        }
    }
    
    func shouldBlockAds() async throws -> Bool {
        let result = Task<Bool, Error> {
            if let userType = try? await AppSessionManager.shared.userType(),
               userType == .premium,
               UserDefaults.standard.bool(forKey: SettingsKeys.isEnabledBlocker) {
                return true
            } else {
                return false
            }
        }
        return try await result.value
    }
    
    func disableAdBlock(forWebView webView: WKWebView?) {
//        self.ruleLists = []
        DispatchQueue.main.async {
            webView?.configuration.userContentController.removeAllContentRuleLists()
        }
    }
    
    func saveDomainToWhiteListIfNotSavedYet(domain: String, completion: @escaping((_ savingStatus: SaveWhitelistActionStatus) -> Void)) {
        if var domains = UserDefaults.standard.object(forKey: SettingsKeys.domains) as? [String] {
            if !domains.contains(domain) {
                domains.insert(domain, at: 0)
                UserDefaults.standard.set(domains, forKey: SettingsKeys.domains)
                UserDefaults.standard.synchronize()
                completion(.saved)
            } else {
                completion(.alreadyContains)
            }
        } else {
            UserDefaults.standard.set([domain], forKey: SettingsKeys.domains)
            UserDefaults.standard.synchronize()
            completion(.saved)
        }
    }
}

// MARK: Download easylists

extension AdBlockManager {
    func updateEasyListIfNeeded(completion: (() -> Void)?) {
        if let savedDate = EasyListsStorage.shared.lastModifiedSince1970(filenames: EasyListsName.names) {
            let currentDate = Date()
            let timeInterval = currentDate.timeIntervalSince(savedDate)
            if timeInterval > self.easyListUpdateTimeInterval {
                self.downloadEasyLists(completion: completion)
            }
        } else {
            self.downloadEasyLists(completion: completion)
        }
    }
    
    private func downloadEasyLists(completion: (() -> Void)?) {
        self.removeSavedListsFromDocumentDirectory(completion: { [weak self] in
            guard let sSelf = self else { return }
            let group = DispatchGroup()
            for easyListName in EasyListsName.names {
                guard let url = easyListName.url else { continue }
                group.enter()
                sSelf.downloadTextFile(filename: easyListName, url: url, completion: { result in
                    UserDefaults.standard.set(false, forKey: easyListName.rawValue)
                    group.leave()
                })
            }
            
            group.notify(queue: .main, execute: {
                completion?()
            })
        })
    }
    
    private func downloadTextFile(filename: EasyListsName, url: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.fileDoesNotExist)))
                return
            }
            
            let text = String(decoding: data, as: UTF8.self)
            EasyListsStorage.shared.saveResponseToFile(filename: filename, response: httpResponse, data: data, completion: { url, error in
                completion(.success(text))
            })
        }
        task.resume()
    }
    
    private func removeSavedListsFromDocumentDirectory(completion: (() -> Void)?) {
        let group = DispatchGroup()
        for easyListName in EasyListsName.names {
            group.enter()
            EasyListsStorage.shared.deleteFileFromDocuments(filename: easyListName, completion: { error in
                group.leave()
            })
        }
        group.notify(queue: .main, execute: {
            completion?()
        })
    }
    
}
