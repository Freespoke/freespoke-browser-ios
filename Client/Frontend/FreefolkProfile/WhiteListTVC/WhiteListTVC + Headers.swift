// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

extension WhiteListTVC {
    
    func prepareHeaders(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sections = self.whiteListViewModel.getSections()
        switch sections[section] {
        case .blockAds(let title, _):
            return self.prepareBlockAdsHeader(title: title, tableView)
        case .whiteList(let title, let body, _):
            return self.prepareWhiteListHeader(title: title, body: body, tableView)
        }
    }
    
    private func prepareBlockAdsHeader(title: String, _ tableView: UITableView) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: WhiteListHeaderView.reuseIdentifier) as? WhiteListHeaderView
        header?.setData(title: title)
        return header
    }
    
    private func prepareWhiteListHeader(title: String, body: String, _ tableView: UITableView) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: WhiteListHeaderView.reuseIdentifier) as? WhiteListHeaderView
        header?.setData(title: title, body: body)
        return header
    }
}
