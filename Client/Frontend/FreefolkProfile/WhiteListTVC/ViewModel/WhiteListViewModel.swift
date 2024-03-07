// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

final class WhiteListViewModel {
    
    weak var delegate: WhiteListDelegate?
    private var sections: [WhiteListSectionsType] = []
    
    init(delegate: WhiteListDelegate? = nil) {
        self.setDomains()
        self.delegate = delegate
        self.prepareSections()
    }
    
    private func setDomains() {
        let domains: [String] = ["google.com", "facebook.com", "domain.com", "domain.com", "domain.com", "domain.com"]
        UserDefaults.standard.set(domains, forKey: SettingsKeys.domains)
    }
    
    private func prepareSections() {
        let addBlockerSection: WhiteListSectionsType = .blockAds(title: LocalizationConstants.adBlockStr, cells: [.blockAdsCell])
        let whiteListSection: WhiteListSectionsType = .whiteList(title: LocalizationConstants.whiteListStr, body: LocalizationConstants.descriptionStr, cells: self.getCellsForWhiteList())
        self.sections = []
        self.sections.append(addBlockerSection)
        self.sections.append(whiteListSection)
    }
    
    private func getCellsForWhiteList() -> [WhiteListCellsType] {
        var cells: [WhiteListCellsType] = []
        cells.append(.btnActionCell(title: LocalizationConstants.addWebsiteToWhiteListStr))
        guard let domains = UserDefaults.standard.object(forKey: SettingsKeys.domains) as? [String] else { return cells }
        cells += domains.enumerated().map({ .domainCell(domain: $1, index: $0) })
        return cells
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
        domains.remove(at: index)
        UserDefaults.standard.set(domains, forKey: SettingsKeys.domains)
        self.prepareSections()
        self.delegate?.reloadTableView()
    }
    
}
