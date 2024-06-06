// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

import Foundation
import Shared
import Storage

class TrendingNewsModel {
    struct UX {
        static let cellEstimatedSize: CGSize = CGSize(width: 85, height: 94)
        static let cardSpacing: CGFloat = 16
        static let minCards: Int = 4
    }

    weak var delegate: HomepageDataModelDelegate?
    var theme: Theme
    
    private var trendingStory: StoryFeedModel?
    
    var closureDidTapOnViewRecentlyCell: ((UIButton) -> Void)?
    var closureDidTappedOnTrendingCell: ((StoryFeedItemModel) -> Void)?
    
    init(profile: Profile,
         isZeroSearch: Bool = false,
         theme: Theme,
         wallpaperManager: WallpaperManager) {
        self.theme = theme
    }

    func tilePressed(site: TopSite, position: Int) { }

    // MARK: - Telemetry

    func sendImpressionTelemetry(_ homeTopSite: TopSite, position: Int) { }

    private func topSitePressTracking(homeTopSite: TopSite, position: Int) { }

    private func hasSentImpressionForTile(_ homeTopSite: TopSite) -> Bool { return true }

    // MARK: - Context actions

    func hideURLFromTopSites(_ site: Site) {  }

    func pinTopSite(_ site: Site) { }

    func removePinTopSite(_ site: Site) {  }
    
    func updateTrendingNews(trendingNews: StoryFeedModel) {
        self.trendingStory = trendingNews
        self.delegate?.reloadView()
    }
}

// MARK: HomeViewModelProtocol
extension TrendingNewsModel: HomepageViewModelProtocol, FeatureFlaggable {
    
    var sectionType: HomepageSectionType {
        return .trendingNews
    }

    var headerViewModel: LabelButtonHeaderViewModel {
        return LabelButtonHeaderViewModel(
            title: HomepageSectionType.trendingNews.title,
            isButtonHidden: true)
    }

    var isEnabled: Bool {
        return featureFlags.isFeatureEnabled(.topSites, checking: .buildAndUser)
    }

    func numberOfItemsInSection() -> Int {
        let count = self.trendingStory?.stories?.count ?? 0
        return count > 4 ? (4 + 1) : (count + 1)
    }

    func section(for traitCollection: UITraitCollection, size: CGSize) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(40)
        )

        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     subitem: item,
                                                     count: 1)
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(0)
        let section = NSCollectionLayoutSection(group: group)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                heightDimension: .estimated(34))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)
        section.boundarySupplementaryItems = [header]

        let leadingInset = HomepageViewModel.UX.leadingInset(traitCollection: traitCollection)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: leadingInset,
            bottom: HomepageViewModel.UX.spacingBetweenSections,
            trailing: leadingInset)

        section.interGroupSpacing = 0

        return section
    }

    func refreshData(for traitCollection: UITraitCollection,
                     size: CGSize,
                     isPortrait: Bool = UIWindow.isPortrait,
                     device: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom) {  }

    func screenWasShown() { }

    func setTheme(theme: Theme) {
        self.theme = theme
    }
}

// MARK: - FxHomeSectionHandler
extension TrendingNewsModel: HomepageSectionHandler {
    func configure(_ collectionView: UICollectionView,
                   at indexPath: IndexPath) -> UICollectionViewCell {
        let isLastItem: Bool = self.numberOfItemsInSection()  == indexPath.row + 1
        switch isLastItem {
        case true:
            guard let cell = collectionView.dequeueReusableCell(cellType: ViewRecentlyCell.self, for: indexPath) else { return UICollectionViewCell() }
            cell.closureTappedOnBtnAction = { [weak self] btn in self?.closureDidTapOnViewRecentlyCell?(btn) }
            cell.applyTheme(theme: self.theme)
            return cell
        case false:
            guard let cell = collectionView.dequeueReusableCell(cellType: TrendingItemCell.self, for: indexPath) else { return UICollectionViewCell() }
            if (self.trendingStory?.stories?.count ?? 0) > indexPath.row, let trendingModel = self.trendingStory?.stories?[indexPath.row] {
                let name: String =  trendingModel.name ?? ""
                cell.setData(title: name)
            }
            cell.applyTheme(theme: self.theme)
            return cell
        }
    }

    func configure(_ cell: UICollectionViewCell, at indexPath: IndexPath) -> UICollectionViewCell { return UICollectionViewCell() }

    func didSelectItem(at indexPath: IndexPath,
                       homePanelDelegate: HomePanelDelegate?,
                       libraryPanelDelegate: LibraryPanelDelegate?) {
        guard let stories = self.trendingStory?.stories else { return }
        guard stories.count > indexPath.row else { return }
        guard let item = self.trendingStory?.stories?[indexPath.row] else { return }
        self.closureDidTappedOnTrendingCell?(item)
    }

    func handleLongPress(with collectionView: UICollectionView, indexPath: IndexPath) { }
}
