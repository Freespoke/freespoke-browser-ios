// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

extension WhiteListTVC {
    func prepareCells(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sections = self.viewModel.getSections()
        switch sections[indexPath.section] {
        case .blockAds(_, cells: let cells):
            return self.prepareCellsForBlockAdsSection(tableView, cellForRowAt: indexPath, cells: cells)
        case .whiteList(_, _, cells: let cells):
            return self.prepareCellsForWhiteListSection(tableView, cellForRowAt: indexPath, cells: cells)
        }
    }
    // MARK: Cells for ad blocker section
    private func prepareCellsForBlockAdsSection(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, cells: [BlockAdsCellsType]) -> UITableViewCell {
        switch cells[indexPath.row] {
        case .blockAdsCell:
            return self.prepareAdBlockerCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    private func prepareAdBlockerCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AdBlockerCell.reuseIdentifier, for: indexPath) as? AdBlockerCell else { return UITableViewCell() }
        cell.closureTappedOnBtnSwitch = { [weak self] in
            guard let self = self else { return }
            self.closureTappedOnBtnSwitch?()
            self.viewModel.updateSections()
        }
        cell.applyTheme(currentTheme: self.themeManager.currentTheme)
        return cell
    }
    // MARK: Cells for white list section
    private func prepareCellsForWhiteListSection(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, cells: [WhiteListCellsType]) -> UITableViewCell {
        switch cells[indexPath.row] {
        case .enterDomainCell(let placeholder, let domain):
            return prepareTxtDomainCell(tableView, cellForRowAt: indexPath, placeholder: placeholder, domain: domain)
        case .btnActionCell(let title):
            return self.prepareBtnActionCell(tableView, cellForRowAt: indexPath, title: title)
        case .domainCell(let domain, let index):
            return self.prepareDomainCell(tableView, cellForRowAt: indexPath, domain: domain, index: index)
        }
    }
    
    private func prepareTxtDomainCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, placeholder: String, domain: String?) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DomainTxtCell.reuseIdentifier, for: indexPath) as? DomainTxtCell else { return UITableViewCell() }
        cell.setData(placeholder: placeholder, domain: domain, currentTheme: self.themeManager.currentTheme)
        
        cell.txtFieldTextChangedClosure = { [weak self] text in
            guard let self = self else { return }
            self.viewModel.setDomain(domain: text)
            self.updateAddWebsiteButtonState()
        }
        
        return cell
    }
    
    fileprivate func updateAddWebsiteButtonState() {
        for case let cell as WhiteListBtnCell in self.tableView.visibleCells {
            cell.updateButtonState(isEnteredTextDomain: self.viewModel.isEnteredTextDomain())
        }
    }
    
    private func prepareBtnActionCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, title: String) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WhiteListBtnCell.reuseIdentifier, for: indexPath) as? WhiteListBtnCell else { return UITableViewCell() }
        cell.setData(currentTheme: self.themeManager.currentTheme, title: title)
        cell.updateButtonState(isEnteredTextDomain: self.viewModel.isEnteredTextDomain())
        cell.closureTappedonBtnAction = { [weak self] in
            guard let self = self else { return }
            self.viewModel.saveDomainIfNotSavedYet()
        }
        return cell
    }
    
    private func prepareDomainCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, domain: String, index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WhiteListDomainCell.reuseIdentifier, for: indexPath) as? WhiteListDomainCell else { return UITableViewCell() }
        cell.closureTappedOnBtnRemoveDomain = { [weak self] in
            self?.viewModel.removeDomainsBy(index: index)
        }
        cell.setDomain(domain: domain)
        cell.updateTheme(currentTheme: self.themeManager.currentTheme)
        return cell
    }
}