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
//    var isZeroSearch: Bool
    var theme: Theme
//    var tilePressedHandler: ((Site, Bool) -> Void)?
//    var tileLongPressedHandler: ((Site, UIView?) -> Void)?

//    private let profile: Profile
//    private var sentImpressionTelemetry = [String: Bool]()
//    private var topSites: [TopSite] = []
//    private let dimensionManager: TopSitesDimension
//    private var numberOfItems: Int = 0

//    private let topSitesDataAdaptor: TopSitesDataAdaptor
//    private let topSiteHistoryManager: TopSiteHistoryManager
//    private let googleTopSiteManager: GoogleTopSiteManager
//    private var wallpaperManager: WallpaperManager
    
    private var trendingStory: StoryFeedModel?
    
    init(profile: Profile,
         isZeroSearch: Bool = false,
         theme: Theme,
         wallpaperManager: WallpaperManager) {
//        self.profile = profile
//        self.isZeroSearch = isZeroSearch
        self.theme = theme
//        self.dimensionManager = TopSitesDimensionImplementation()

//        self.topSiteHistoryManager = TopSiteHistoryManager(profile: profile)
//        self.googleTopSiteManager = GoogleTopSiteManager(prefs: profile.prefs)
//        let adaptor = TopSitesDataAdaptorImplementation(profile: profile,
//                                                        topSiteHistoryManager: topSiteHistoryManager,
//                                                        googleTopSiteManager: googleTopSiteManager)
//        topSitesDataAdaptor = adaptor
//        self.wallpaperManager = wallpaperManager
//        adaptor.delegate = self
    }

    func tilePressed(site: TopSite, position: Int) {
//        topSitePressTracking(homeTopSite: site, position: position)
//        tilePressedHandler?(site.site, site.isGoogleURL)
    }

    // MARK: - Telemetry

    func sendImpressionTelemetry(_ homeTopSite: TopSite, position: Int) {
//        guard !hasSentImpressionForTile(homeTopSite) else { return }
//        homeTopSite.impressionTracking(position: position)
    }

    private func topSitePressTracking(homeTopSite: TopSite, position: Int) {
//        // Top site extra
//        let type = homeTopSite.getTelemetrySiteType()
//        let topSiteExtra = [TelemetryWrapper.EventExtraKey.topSitePosition.rawValue: "\(position)",
//                            TelemetryWrapper.EventExtraKey.topSiteTileType.rawValue: type]
//
//        // Origin extra
//        let originExtra = TelemetryWrapper.getOriginExtras(isZeroSearch: isZeroSearch)
//        let extras = originExtra.merge(with: topSiteExtra)
//
//        TelemetryWrapper.recordEvent(category: .action,
//                                     method: .tap,
//                                     object: .topSiteTile,
//                                     value: nil,
//                                     extras: extras)
//
//        // Sponsored tile specific telemetry
//        if let tile = homeTopSite.site as? SponsoredTile {
//            SponsoredTileTelemetry.sendClickTelemetry(tile: tile, position: position)
//        }
    }

    private func hasSentImpressionForTile(_ homeTopSite: TopSite) -> Bool {
//        guard sentImpressionTelemetry[homeTopSite.site.url] != nil else {
//            sentImpressionTelemetry[homeTopSite.site.url] = true
//            return false
//        }
        return true
    }

    // MARK: - Context actions

    func hideURLFromTopSites(_ site: Site) {
//        topSiteHistoryManager.removeDefaultTopSitesTile(site: site)
//        // We make sure to remove all history for URL so it doesn't show anymore in the
//        // top sites, this is the approach that Android takes too.
//        self.profile.places.deleteVisitsFor(url: site.url).uponQueue(.main) { _ in
//            NotificationCenter.default.post(name: .TopSitesUpdated, object: self)
//        }
    }

    func pinTopSite(_ site: Site) {
//        _ = profile.pinnedSites.addPinnedTopSite(site)
    }

    func removePinTopSite(_ site: Site) {
//        googleTopSiteManager.removeGoogleTopSite(site: site)
//        topSiteHistoryManager.removeTopSite(site: site)
    }
    
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
        return count > 4 ? 4 : count//numberOfItems
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
                     device: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom) {
//        let interface = TopSitesUIInterface(trait: traitCollection,
//                                            availableWidth: size.width)
//        
//        print("top sites Count: \(topSites.count)")
//        
//        let sectionDimension = dimensionManager.getSectionDimension(for: topSites,
//                                                                    numberOfRows: topSitesDataAdaptor.numberOfRows,
//                                                                    interface: interface)
//        topSitesDataAdaptor.recalculateTopSiteData(for: sectionDimension.numberOfTilesPerRow)
//        topSites = topSitesDataAdaptor.getTopSitesData()
        
//        numberOfItems = self.breakingNews?.data.count ?? 0//sectionDimension.numberOfRows * sectionDimension.numberOfTilesPerRow
    }

    func screenWasShown() {
//        sentImpressionTelemetry = [String: Bool]()
    }

    func setTheme(theme: Theme) {
        self.theme = theme
    }
}

// MARK: - FxHomeTopSitesManagerDelegate
//extension TrendingNewsModel: TopSitesManagerDelegate {
//    func didLoadNewData() {
//        ensureMainThread {
//            self.topSites = self.topSitesDataAdaptor.getTopSitesData()
//            guard self.isEnabled else { return }
//            self.delegate?.reloadView()
//        }
//    }
//}

// MARK: - FxHomeSectionHandler
extension TrendingNewsModel: HomepageSectionHandler {
    func configure(_ collectionView: UICollectionView,
                   at indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(cellType: TrendingItemCell.self, for: indexPath) {
            if (self.trendingStory?.stories?.count ?? 0) > indexPath.row, let trendingModel = self.trendingStory?.stories?[indexPath.row] {
                let name: String =  trendingModel.name ?? ""
                cell.setData(title: name)
            }
            
            cell.applyTheme(theme: self.theme)
            return cell
        } else {
            return UICollectionViewCell()
        }
        
    }

    func configure(_ cell: UICollectionViewCell,
                   at indexPath: IndexPath) -> UICollectionViewCell {
        // Setup is done through configure(collectionView:indexPath:), shouldn't be called
        return UICollectionViewCell()
    }

    func didSelectItem(at indexPath: IndexPath,
                       homePanelDelegate: HomePanelDelegate?,
                       libraryPanelDelegate: LibraryPanelDelegate?) {
        guard let stories = self.trendingStory?.stories else { return }
        guard stories.count > indexPath.row else { return }
        guard let item = self.trendingStory?.stories?[indexPath.row] else { return }
        homePanelDelegate?.didTappedOnTrendingCell(storyFeedItemModel: item)
    }

    func handleLongPress(with collectionView: UICollectionView, indexPath: IndexPath) {
//        guard let tileLongPressedHandler = tileLongPressedHandler,
//              let site = topSites[safe: indexPath.row]?.site
//        else { return }
//
//        let sourceView = collectionView.cellForItem(at: indexPath)
//        tileLongPressedHandler(site, sourceView)
    }
}
