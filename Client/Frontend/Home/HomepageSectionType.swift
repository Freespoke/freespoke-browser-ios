// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

enum HomepageSectionType: Int, CaseIterable {
    case messageCard
    case topSites
    case trendingNews
    case jumpBackIn
    case recentlySaved
    case historyHighlights
    case pocket
    case customizeHome

    var title: String? {
        switch self {
        case .pocket: return .FirefoxHomepage.Pocket.SectionTitle
        case .jumpBackIn: return .FirefoxHomeJumpBackInSectionTitle
        case .recentlySaved: return .RecentlySavedSectionTitle
        case .topSites: return .MyBookmarksTitle
        case .trendingNews: return .TrendingNewsTitle
        case .historyHighlights: return .FirefoxHomepage.HistoryHighlights.Title
        default: return nil
        }
    }

    var cellIdentifier: String {
        switch self {
        case .messageCard: return HomepageMessageCardCell.cellIdentifier
        case .topSites: return "" // Top sites has more than 1 cell type, dequeuing is done through FxHomeSectionHandler protocol
        case .trendingNews: return TrendingItemCell.cellIdentifier
        case .pocket: return "" // Pocket has more than 1 cell type, dequeuing is done through FxHomeSectionHandler protocol
        case .jumpBackIn: return "" // JumpBackIn has more than 1 cell type, dequeuing is done through FxHomeSectionHandler protocol
        case .recentlySaved: return RecentlySavedCell.cellIdentifier
        case .historyHighlights: return HistoryHighlightsCell.cellIdentifier
        case .customizeHome: return CustomizeHomepageSectionCell.cellIdentifier
        }
    }

    static var cellTypes: [ReusableCell.Type] {
        return [HomepageMessageCardCell.self,
                BookmarkItemCell.self,
                TrendingItemCell.self,
                ViewRecentlyCell.self,
                EmptyTopSiteCell.self,
                JumpBackInCell.self,
                PocketDiscoverCell.self,
                PocketStandardCell.self,
                RecentlySavedCell.self,
                HistoryHighlightsCell.self,
                CustomizeHomepageSectionCell.self,
                SyncedTabCell.self
        ]
    }

    init(_ section: Int) {
        self.init(rawValue: section)!
    }
}
