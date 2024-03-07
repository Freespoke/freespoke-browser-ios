// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

enum WhiteListSectionsType {
    case blockAds(title: String, cells: [BlockAdsCellsType])
    case whiteList(title: String, body: String, cells: [WhiteListCellsType])
    
    func getNumberOfItems() -> Int {
        switch self {
        case .blockAds(_, let cells):
            return cells.count
        case .whiteList(_, _, let cells):
            return cells.count
        }
    }
}

enum BlockAdsCellsType {
    case blockAdsCell
}

enum WhiteListCellsType {
    case btnActionCell(title: String)
    case domainCell(domain: String, index: Int)
}
