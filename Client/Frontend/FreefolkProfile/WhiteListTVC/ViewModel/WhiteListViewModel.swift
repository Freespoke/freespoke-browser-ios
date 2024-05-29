// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

final class WhiteListViewModel {
    weak var delegate: WhiteListDelegate?
    private var sections: [WhiteListSectionsType] = []
    
    private var currentEnteredDomain: String?
    
    init(delegate: WhiteListDelegate? = nil) {
        self.delegate = delegate
        self.setupSections()
    }
    
    private func setupSections() {
        let addBlockerSection: WhiteListSectionsType = .blockAds(title: LocalizationConstants.manageAdBlockScreenTitle.uppercased(), cells: [.blockAdsCell])
        let whiteListSection: WhiteListSectionsType = .whiteList(title: LocalizationConstants.whiteListStr, body: LocalizationConstants.adBlockDescriptionStr, cells: self.getCellsForWhiteList())
        self.sections = []
        self.sections.append(addBlockerSection)
        
        if UserDefaults.standard.bool(forKey: SettingsKeys.isEnabledBlocker) {
            self.sections.append(whiteListSection)
        }
        
        self.delegate?.reloadTableView()
    }
    
    private func getCellsForWhiteList() -> [WhiteListCellsType] {
        var cells: [WhiteListCellsType] = []
        cells.append(.enterDomainCell(placeholder: LocalizationConstants.adBlockEnterDomainPlaceholder, domain: self.currentEnteredDomain))
        cells.append(.btnActionCell(title: LocalizationConstants.addWebsiteToWhiteListStr))
        guard let domains = UserDefaults.standard.object(forKey: SettingsKeys.domains) as? [String] else { return cells }
        cells += domains.enumerated().map({ .domainCell(domain: $1, index: $0) })
        return cells
    }
    
    func updateSections() {
        self.setupSections()
    }
    
    func getNumberOfSection() -> Int {
        return self.sections.count
    }
    
    func getNumberOfRowsInSection(section: Int) -> Int {
        return self.sections[section].getNumberOfItems()
    }
    
    func getSections() -> [WhiteListSectionsType] {
        return self.sections
    }
    
    func removeDomainsBy(index: Int) {
        guard var domains = UserDefaults.standard.object(forKey: SettingsKeys.domains) as? [String] else { return }
        guard index < domains.count else { return }
        let domain = domains[index]
        self.delegate?.showConfirmAlertForDeleteDomain(domain: domain,
                                                       completion: { [weak self] in
            guard let self = self else { return }
            domains.remove(at: index)
            UserDefaults.standard.set(domains, forKey: SettingsKeys.domains)
            UserDefaults.standard.synchronize()
            self.setupSections()
            let userInfo: [String: Any] = [NotificationKeyNameForValue.host.rawValue: domain]
            NotificationCenter.default.post(name: NSNotification.Name.enableAdBlockerForCurrentDomain, object: nil, userInfo: userInfo)
        })
    }
    
    func setDomain(domain: String?) {
        self.currentEnteredDomain = domain
    }
    
    func isEnteredTextDomain() -> Bool {
        guard let domain = self.currentEnteredDomain,
              domain.isValidDomain()
        else {
            return false
        }
        return true
    }
    
    func saveDomainIfNotSavedYet() {
        guard let domain = self.currentEnteredDomain else { return }
        AdBlockManager.shared.saveDomainToWhiteListIfNotSavedYet(domain: domain,
                                                                 completion: { [weak self] savingStatus in
            guard let self = self else { return }
            switch savingStatus {
            case .saved:
                UIUtils.showOkAlertInNewWindow(title: "Add to Whitelist",
                                               message: "\(domain) has been added to your adblock whitelist. Advertisements will not be blocked on this site.")
                
            case .alreadyContains:
                UIUtils.showOkAlertInNewWindow(title: "Add to Whitelist",
                                               message: "You already have \(domain) added to your whitelist.")
            }
            self.currentEnteredDomain = ""
            self.setupSections()
        })
    }
}
