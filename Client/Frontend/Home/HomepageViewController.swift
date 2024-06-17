// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Shared
import UIKit
import Storage
import SyncTelemetry
import MozillaAppServices
import Common

class HomepageViewController: UIViewController, HomePanel, FeatureFlaggable, Themeable {
    // MARK: - Typealiases
    private typealias a11y = AccessibilityIdentifiers.FirefoxHomepage
    typealias SendToDeviceDelegate = InstructionsViewDelegate & DevicePickerViewControllerDelegate
    
    // MARK: - Operational Variables
    weak var homePanelDelegate: HomePanelDelegate? {
        didSet {
            viewModel.messageCardViewModel.homepanelDelegate = homePanelDelegate
        }
    }
    weak var libraryPanelDelegate: LibraryPanelDelegate?
    weak var sendToDeviceDelegate: SendToDeviceDelegate? {
        didSet {
            contextMenuHelper.sendToDeviceDelegate = sendToDeviceDelegate
        }
    }
    
    var delegate: FreespokeHomepageDelegate?
    
    private var viewModel: HomepageViewModel
    
    private var contextMenuHelper: HomepageContextMenuHelper
    private var tabManager: TabManagerProtocol
    
    private var urlBar: URLBarViewProtocol
    private var userDefaults: UserDefaultsInterface
    private lazy var wallpaperView: WallpaperBackgroundView = .build { _ in }
    private var jumpBackInContextualHintViewController: ContextualHintViewController
    private var syncTabContextualHintViewController: ContextualHintViewController
    private var logger: Logger
    
    var themeManager: ThemeManager
    var notificationCenter: NotificationProtocol
    var themeObserver: NSObjectProtocol?
    
    private let freespokeHomepageViewModel = FreespokeHomepageViewModel()
    private lazy var freespokeHomepageView: FreespokeHomepage = {
        let view = FreespokeHomepage(viewModel: self.freespokeHomepageViewModel)
        return view
    }()
    
    var isHome = false
    var isNewTab = false
    var isSearching = false
    
    var profileVC: FreefolkProfileVC?
    
    // Background for status bar
    private lazy var statusBarView: UIView = {
        let statusBarFrame = statusBarFrame ?? CGRect.zero
        let statusBarView = UIView(frame: statusBarFrame)
        view.addSubview(statusBarView)
        statusBarView.isHidden = true
        return statusBarView
    }()
    
    lazy var searchPageView: SearchPageView = {
        let view = SearchPageView(viewModel: self.viewModel, freespokeHomepageViewModel: self.freespokeHomepageViewModel, themeManager: self.themeManager, delegate: self)
        return view
    }()
    
    var currentTab: Tab? {
        return tabManager.selectedTab
    }
    
    var profile: Profile?
    
    private var portraitPhoneConstraints: [NSLayoutConstraint] = []
    private var landscapePhoneConstraints: [NSLayoutConstraint] = []
    private var portraitPadConstraints: [NSLayoutConstraint] = []
    private var landscapePadConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Initializers
    init(profile: Profile,
         tabManager: TabManagerProtocol,
         urlBar: URLBarViewProtocol,
         userDefaults: UserDefaultsInterface = UserDefaults.standard,
         themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default,
         logger: Logger = DefaultLogger.shared
    ) {
        self.profile = profile
        self.urlBar = urlBar
        self.tabManager = tabManager
        self.userDefaults = userDefaults
        let isPrivate = tabManager.selectedTab?.isPrivate ?? true
        self.viewModel = HomepageViewModel(profile: profile,
                                           isPrivate: isPrivate,
                                           tabManager: tabManager,
                                           urlBar: urlBar,
                                           theme: themeManager.currentTheme)
        
        let jumpBackInContextualViewModel = ContextualHintViewModel(forHintType: .jumpBackIn,
                                                                    with: viewModel.profile)
        self.jumpBackInContextualHintViewController = ContextualHintViewController(with: jumpBackInContextualViewModel)
        let syncTabContextualViewModel = ContextualHintViewModel(forHintType: .jumpBackInSyncedTab,
                                                                 with: viewModel.profile)
        self.syncTabContextualHintViewController = ContextualHintViewController(with: syncTabContextualViewModel)
        self.contextMenuHelper = HomepageContextMenuHelper(viewModel: viewModel)
        
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        self.logger = logger
        super.init(nibName: nil, bundle: nil)
        
        contextMenuHelper.delegate = self
        contextMenuHelper.getPopoverSourceRect = { [weak self] popoverView in
            guard let self = self else { return CGRect() }
            return self.getPopoverSourceRect(sourceView: popoverView)
        }
        
        self.subscribeNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        jumpBackInContextualHintViewController.stopTimer()
        syncTabContextualHintViewController.stopTimer()
        notificationCenter.removeObserver(self)
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWallpaperView()
        self.addSubviews()
        addContentStackViewConstraints()
        
        // Delay setting up the view model delegate to ensure the views have been configured first
        self.viewModel.delegate = self
        
        // add FreespokeHomepageView
        self.addFreespokeHomepageView()
        self.addFreespokeHomepageViewConstraints()
        
        self.freespokeHomepageView.profileIconTapClosure = { [weak self] in
            AnalyticsManager.trackMatomoEvent(category: .appProfileCategory,
                                              action: AnalyticsManager.MatomoAction.appProfileHomePageAvatarClickedAction.rawValue,
                                              name: AnalyticsManager.MatomoName.clickName)
            self?.displayFreefolkProfileVC()
        }
        
        self.freespokeHomepageView.updateView(decodedJWTToken: AppSessionManager.shared.decodedJWTToken)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        //view.addGestureRecognizer(tap)
        
        setupSectionsAction()
        reloadView()
        
        listenForThemeChange(view)
        applyTheme()
    }
    
    private func addFreespokeHomepageView() {
        self.freespokeHomepageView.delegate = self
        self.view.addSubview(self.freespokeHomepageView)
    }
    
    private func addFreespokeHomepageViewConstraints() {
        self.freespokeHomepageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.freespokeHomepageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.freespokeHomepageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.freespokeHomepageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.freespokeHomepageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func displayFreefolkProfileVC() {
        DispatchQueue.main.async { [ weak self] in
            guard let  self = self else { return }
            self.profileVC = FreefolkProfileVC(viewModel: FreefolkProfileViewModel())
            
            guard let profileVC = self.profileVC else { return }
            profileVC.getInTouchClosure = { [weak self] in
                self?.showURL(url: Constants.getInTouchURL.rawValue)
                TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .help)
                profileVC.motionDismissViewController()
            }
            
            profileVC.appThemeClickedClosure = { [weak self] in
                guard let  self = self else { return }
                let themeSettingsController = ThemeSettingsController()
                self.present(themeSettingsController, animated: true)
            }
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func displayManageWhiteListVC() {
        DispatchQueue.main.async { [ weak self] in
            guard let self = self else { return }
            let vc = WhiteListTVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func checkFreespokeHomepage() {
        switch self.isHome {
        case true:
            switch self.isNewTab {
            case true:
                self.shouldHideHomePageViewWithAnimation(shouldHide: self.isSearching)
            case false:
                self.shouldHideHomePageViewWithAnimation(shouldHide: self.isSearching)
            }
        case false:
            self.shouldHideHomePageViewWithAnimation(shouldHide: self.isSearching)
        }
    }
    
    private func shouldHideHomePageViewWithAnimation(shouldHide: Bool) {
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.freespokeHomepageView.alpha = shouldHide ? 0 : 1
            })
    }
    
    func reloadFreespokeHomepage() {
        self.freespokeHomepageView.reloadAllItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.freespokeHomepageView.updateView(decodedJWTToken: AppSessionManager.shared.decodedJWTToken)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        jumpBackInContextualHintViewController.stopTimer()
        syncTabContextualHintViewController.stopTimer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.wallpaperView.updateImageForOrientationChange()
        self.activateCurrentConstraints()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            reloadOnRotation(newSize: size)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme()
        
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass
            || previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass {
            reloadOnRotation(newSize: view.frame.size)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // make sure the keyboard is dismissed when wallpaper onboarding is shown
        // Can be removed once underlying problem is solved (FXIOS-4904)
        if let presentedViewController = presentedViewController,
           presentedViewController.isKind(of: BottomSheetViewController.self) {
            self.dismissKeyboard()
        }
    }
    
    private func addSubviews() {
        view.addSubview(self.searchPageView)
    }
    
    // MARK: - Layout
    func addContentStackViewConstraints() {
        self.searchPageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints for iPhone
        self.portraitPhoneConstraints = [
            self.searchPageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            self.searchPageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.searchPageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.searchPageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        
        self.landscapePhoneConstraints = [
            self.searchPageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            self.searchPageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.searchPageView.widthAnchor.constraint(equalTo: self.view.widthAnchor,
                                                       multiplier: Constants.DrawingSizes.iPadContentWidthFactorLandscape),
            self.searchPageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        // Constraints for iPad
        self.portraitPadConstraints = [
            self.searchPageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            self.searchPageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.searchPageView.widthAnchor.constraint(equalTo: self.view.widthAnchor,
                                                       multiplier: Constants.DrawingSizes.iPadContentWidthFactorPortrait),
            self.searchPageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        self.landscapePadConstraints = [
            self.searchPageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            self.searchPageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.searchPageView.widthAnchor.constraint(equalTo: self.view.widthAnchor,
                                                       multiplier: Constants.DrawingSizes.iPadContentWidthFactorLandscape),
            self.searchPageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ]
        self.activateCurrentConstraints()
    }
      
      private func activateCurrentConstraints() {
          // Deactivate Constraints
          NSLayoutConstraint.deactivate(self.portraitPhoneConstraints)
          NSLayoutConstraint.deactivate(self.landscapePhoneConstraints)
          NSLayoutConstraint.deactivate(self.portraitPadConstraints)
          NSLayoutConstraint.deactivate(self.landscapePadConstraints)
          
          // Activate Constraints
          let currentOrientation = UIDevice.current.orientation
          switch currentOrientation {
          case .portrait, .portraitUpsideDown:
              if UIDevice.current.isPad {
                  NSLayoutConstraint.activate(self.portraitPadConstraints)
              } else {
                  NSLayoutConstraint.activate(self.portraitPhoneConstraints)
              }
          case .landscapeLeft, .landscapeRight:
              if UIDevice.current.isPad {
                  NSLayoutConstraint.activate(self.landscapePadConstraints)
              } else {
                  NSLayoutConstraint.activate(self.landscapePhoneConstraints)
              }
          default:
              if UIDevice.current.isPad {
                  NSLayoutConstraint.activate(self.portraitPadConstraints)
              } else {
                  NSLayoutConstraint.activate(self.portraitPhoneConstraints)
              }
          }
      }
    
    func configureWallpaperView() {
        view.addSubview(wallpaperView)
        NSLayoutConstraint.activate([
            wallpaperView.topAnchor.constraint(equalTo: view.topAnchor),
            wallpaperView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wallpaperView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            wallpaperView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.sendSubviewToBack(wallpaperView)
    }
    
    // MARK: - Homepage view cycle
    /// Normal view controller view cycles cannot be relied on the homepage since the current way of showing and hiding the homepage is through alpha.
    /// This is a problem that need to be fixed but until then we have to rely on the methods here.
    
    func homepageWillAppear(isZeroSearch: Bool) {
        logger.log("\(type(of: self)) will appear", level: .info, category: .lifecycle)
        
        viewModel.isZeroSearch = isZeroSearch
        viewModel.recordViewAppeared()
        notificationCenter.post(name: .HistoryUpdated)
    }
    
    func homepageDidAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.displayWallpaperSelector()
        }
    }
    
    func homepageWillDisappear() {
        jumpBackInContextualHintViewController.stopTimer()
        syncTabContextualHintViewController.stopTimer()
        viewModel.recordViewDisappeared()
    }
    
    // MARK: - Helpers
    
    /// On iPhone, we call reloadOnRotation when the trait collection has changed, to ensure calculation
    /// is done with the new trait. On iPad, trait collection doesn't change from portrait to landscape (and vice-versa)
    /// since it's `.regular` on both. We reloadOnRotation from viewWillTransition in that case.
    private func reloadOnRotation(newSize: CGSize) {
        logger.log("Reload on rotation to new size \(newSize)", level: .info, category: .homepage)
        if presentedViewController as? PhotonActionSheet != nil {
            presentedViewController?.dismiss(animated: false, completion: nil)
        }
        self.searchPageView.reloadOnRotation(newSize: newSize)
    }
    
    private func adjustPrivacySensitiveSections(notification: Notification) {
        guard let dict = notification.object as? NSDictionary,
              let isPrivate = dict[Tab.privateModeKey] as? Bool
        else { return }
        
        let privacySectionState = isPrivate ? "Removing": "Adding"
        logger.log("\(privacySectionState) privacy sensitive sections", level: .info, category: .homepage)
        viewModel.isPrivate = isPrivate
        reloadView()
    }
    
    func applyTheme() {
        let theme = themeManager.currentTheme
        viewModel.theme = theme
        updateStatusBar(theme: theme)
        freespokeHomepageView.applyTheme(currentTheme: theme)
        
        switch theme.type {
        case .light:
            view.backgroundColor = .white //theme.colors.layer1
        case .dark:
            view.backgroundColor = .darkBackground
        }
        self.searchPageView.applyTheme()
    }
    
    func scrollToTop(animated: Bool = false) {
        self.searchPageView.scrollToTop(animated: animated)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {  }
    
    @objc private func dismissKeyboard() {
        if currentTab?.lastKnownUrl?.absoluteString.hasPrefix("internal://") ?? false {
            urlBar.leaveOverlayMode()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Find visible pocket cells that holds pocket stories
        // Relative frame is the collectionView frame plus the status bar height
 
        self.searchPageView.updatePocketCellsWithVisibleRatio()
        updateStatusBar(theme: themeManager.currentTheme)
    }
    
    private func showSiteWithURLHandler(_ url: URL, isGoogleTopSite: Bool = false) {
        let visitType = VisitType.bookmark
        homePanelDelegate?.homePanel(didSelectURL: url, visitType: visitType, isGoogleTopSite: isGoogleTopSite)
    }
    
    func displayWallpaperSelector() {
        let wallpaperManager = WallpaperManager(userDefaults: userDefaults)
        guard wallpaperManager.canOnboardingBeShown(using: viewModel.profile),
              canModalBePresented
        else { return }
        
        self.dismissKeyboard()
        
        let viewModel = WallpaperSelectorViewModel(wallpaperManager: wallpaperManager, openSettingsAction: {
            self.homePanelDidRequestToOpenSettings(at: .wallpaper)
        })
        let viewController = WallpaperSelectorViewController(viewModel: viewModel)
        var bottomSheetViewModel = BottomSheetViewModel()
        bottomSheetViewModel.shouldDismissForTapOutside = false
        let bottomSheetVC = BottomSheetViewController(
            viewModel: bottomSheetViewModel,
            childViewController: viewController
        )
        
        self.present(bottomSheetVC, animated: false, completion: nil)
        userDefaults.set(true, forKey: PrefsKeys.Wallpapers.OnboardingSeenKey)
    }
    
    // Check if we already present something on top of the homepage,
    // if the homepage is actually being shown to the user and if the page is shown from a loaded webpage (zero search).
    private var canModalBePresented: Bool {
        return presentedViewController == nil && view.alpha == 1 && !viewModel.isZeroSearch
    }
    
    // MARK: - Contextual hint
    
    private func prepareAndJumpBackInContextualHint(onView lblTitle: UILabel) {
        guard jumpBackInContextualHintViewController.shouldPresentHint(),
              !viewModel.shouldDisplayHomeTabBanner,
              !lblTitle.frame.isEmpty
        else { return }
        
        // Calculate label header view frame to add as source rect for CFR
        var rect = lblTitle.convert(lblTitle.frame, to: self.searchPageView)
        rect = self.searchPageView.convert(rect, to: view)
        
        jumpBackInContextualHintViewController.configure(
            anchor: view,
            withArrowDirection: .down,
            andDelegate: self,
            presentedUsing: { self.presentContextualHint(contextualHintViewController: self.jumpBackInContextualHintViewController) },
            sourceRect: rect,
            withActionBeforeAppearing: { self.contextualHintPresented(type: .jumpBackIn) },
            andActionForButton: { self.openTabsSettings() })
    }
    
    private func prepareSyncedTabContextualHint(onCell cell: SyncedTabCell) {
        guard syncTabContextualHintViewController.shouldPresentHint(),
              featureFlags.isFeatureEnabled(.contextualHintForJumpBackInSyncedTab, checking: .buildOnly)
        else {
            syncTabContextualHintViewController.unconfigure()
            return
        }
        
        syncTabContextualHintViewController.configure(
            anchor: cell.getContextualHintAnchor(),
            withArrowDirection: .down,
            andDelegate: self,
            presentedUsing: { self.presentContextualHint(contextualHintViewController: self.syncTabContextualHintViewController) },
            withActionBeforeAppearing: { self.contextualHintPresented(type: .jumpBackInSyncedTab) })
    }
    
    @objc private func presentContextualHint(contextualHintViewController: ContextualHintViewController) {
        guard viewModel.viewAppeared, canModalBePresented else {
            contextualHintViewController.stopTimer()
            return
        }
        
        present(contextualHintViewController, animated: true, completion: nil)
        
        UIAccessibility.post(notification: .layoutChanged, argument: contextualHintViewController)
    }
}

extension HomepageViewController: SearchPageViewDelegate {
    func prepareJumpBackInContextualHint(view: UILabel) {
        self.prepareAndJumpBackInContextualHint(onView: view)
    }
    
    func didSelectRowFromSearchPage(indexPath: IndexPath) {
        guard let viewModel = viewModel.getSectionViewModel(shownSection: indexPath.section) as? HomepageSectionHandler else { return }
        viewModel.didSelectItem(at: indexPath, homePanelDelegate: homePanelDelegate, libraryPanelDelegate: libraryPanelDelegate)
    }
}

// MARK: - Actions Handling

private extension HomepageViewController {
    // Setup all the tap and long press actions on cells in each sections
    private func setupSectionsAction() {
        
        // Message card
        viewModel.messageCardViewModel.dismissClosure = { [weak self] in
            self?.reloadView()
        }
        
        // Top sites
        viewModel.topSiteViewModel.tilePressedHandler = { [weak self] site, isGoogle in
            guard let url = site.url.asURL else { return }
            self?.showSiteWithURLHandler(url, isGoogleTopSite: isGoogle)
        }
        
        viewModel.topSiteViewModel.tileLongPressedHandler = { [weak self] (site, sourceView) in
            self?.contextMenuHelper.presentContextMenu(for: site, with: sourceView, sectionType: .topSites)
        }
        
        viewModel.topSiteViewModel.headerButtonAction = { [weak self] button in
            self?.openBookmarks(button)
        }
        
        // Recently saved
        viewModel.recentlySavedViewModel.headerButtonAction = { [weak self] button in
            self?.openBookmarks(button)
        }
        
        // Jumpback in
        viewModel.jumpBackInViewModel.onTapGroup = { [weak self] tab in
            self?.homePanelDelegate?.homePanelDidRequestToOpenTabTray(withFocusedTab: tab)
        }
        
        viewModel.jumpBackInViewModel.headerButtonAction = { [weak self] button in
            self?.openTabTray(button)
        }
        
        viewModel.trendingNewsModel.closureDidTapOnViewRecentlyCell = { [weak self] btn in
            guard let sSelf = self else { return }
            self?.openHistory(btn)
        }
        
        viewModel.jumpBackInViewModel.syncedTabsShowAllAction = { [weak self] in
            self?.homePanelDelegate?.homePanelDidRequestToOpenTabTray(focusedSegment: .syncedTabs)
            
            var extras: [String: String]?
            if let isZeroSearch = self?.viewModel.isZeroSearch {
                extras = TelemetryWrapper.getOriginExtras(isZeroSearch: isZeroSearch)
            }
            TelemetryWrapper.recordEvent(category: .action,
                                         method: .tap,
                                         object: .firefoxHomepage,
                                         value: .jumpBackInSectionSyncedTabShowAll,
                                         extras: extras)
        }
        
        viewModel.jumpBackInViewModel.openSyncedTabAction = { [weak self] tabURL in
            self?.homePanelDelegate?.homePanelDidRequestToOpenInNewTab(tabURL, isPrivate: false, selectNewTab: true)
            
            var extras: [String: String]?
            if let isZeroSearch = self?.viewModel.isZeroSearch {
                extras = TelemetryWrapper.getOriginExtras(isZeroSearch: isZeroSearch)
            }
            TelemetryWrapper.recordEvent(category: .action,
                                         method: .tap,
                                         object: .firefoxHomepage,
                                         value: .jumpBackInSectionSyncedTabOpened,
                                         extras: extras)
        }
        
        viewModel.jumpBackInViewModel.prepareContextualHint = { [weak self] syncedTabCell in
            self?.prepareSyncedTabContextualHint(onCell: syncedTabCell)
        }
        
        viewModel.trendingNewsModel.closureDidTappedOnTrendingCell = { [weak self] storyFeedItemModel in
            guard let sSelf = self else { return }
            guard let urlStr = storyFeedItemModel.links?.seeMoreLink, let url = URL(string: urlStr) else { return }
            sSelf.homePanelDelegate?.homePanel(didSelectURL: url,
                                               visitType: .link,
                                               isGoogleTopSite: false)
        }
        // History highlights 
        viewModel.historyHighlightsViewModel.onTapItem = { [weak self] highlight in
            guard let url = highlight.siteUrl else {
                self?.openHistoryHighlightsSearchGroup(item: highlight)
                return
            }
            
            self?.homePanelDelegate?.homePanel(didSelectURL: url,
                                               visitType: .link,
                                               isGoogleTopSite: false)
        }
        
        viewModel.historyHighlightsViewModel.historyHighlightLongPressHandler = { [weak self] (highlightItem, sourceView) in
            self?.contextMenuHelper.presentContextMenu(for: highlightItem,
                                                       with: sourceView,
                                                       sectionType: .historyHighlights)
        }
        
        viewModel.historyHighlightsViewModel.headerButtonAction = { [weak self] button in
            self?.openHistory(button)
        }
        
        // Pocket
        viewModel.pocketViewModel.onTapTileAction = { [weak self] url in
            self?.showSiteWithURLHandler(url)
        }
        
        viewModel.pocketViewModel.onLongPressTileAction = { [weak self] (site, sourceView) in
            self?.contextMenuHelper.presentContextMenu(for: site, with: sourceView, sectionType: .pocket)
        }
        
        viewModel.pocketViewModel.onScroll = { [weak self] cells in
            guard let window = UIWindow.keyWindow, let self = self else { return }
            self.searchPageView.updatePocketCellsWithVisibleRatio(window.bounds)
        }
        
        // Customize home
        viewModel.customizeButtonViewModel.onTapAction = { [weak self] _ in
            self?.openCustomizeHomeSettings()
        }
    }
    
    private func openHistoryHighlightsSearchGroup(item: HighlightItem) {
        guard let groupItem = item.group else { return }
        
        var groupedSites = [Site]()
        for item in groupItem {
            groupedSites.append(buildSite(from: item))
        }
        let groupSite = ASGroup<Site>(searchTerm: item.displayTitle, groupedItems: groupedSites, timestamp: Date.now())
        
        let asGroupListViewModel = SearchGroupedItemsViewModel(asGroup: groupSite, presenter: .recentlyVisited)
        let asGroupListVC = SearchGroupedItemsViewController(viewModel: asGroupListViewModel, profile: viewModel.profile)
        
        let dismissableController: DismissableNavigationViewController
        dismissableController = DismissableNavigationViewController(rootViewController: asGroupListVC)
        
        self.present(dismissableController, animated: true, completion: nil)
        
        TelemetryWrapper.recordEvent(category: .action,
                                     method: .tap,
                                     object: .firefoxHomepage,
                                     value: .historyHighlightsGroupOpen,
                                     extras: nil)
        
        asGroupListVC.libraryPanelDelegate = libraryPanelDelegate
    }
    
    private func buildSite(from highlight: HighlightItem) -> Site {
        let itemURL = highlight.urlString ?? ""
        return Site(url: itemURL, title: highlight.displayTitle)
    }
    
    func openTabTray(_ sender: UIButton) {
        homePanelDelegate?.homePanelDidRequestToOpenTabTray(withFocusedTab: nil)
        
        if sender.accessibilityIdentifier == a11y.MoreButtons.jumpBackIn {
            TelemetryWrapper.recordEvent(category: .action,
                                         method: .tap,
                                         object: .firefoxHomepage,
                                         value: .jumpBackInSectionShowAll,
                                         extras: TelemetryWrapper.getOriginExtras(isZeroSearch: viewModel.isZeroSearch))
        }
    }
    
    func openBookmarks(_ sender: UIButton) {
        homePanelDelegate?.homePanelDidRequestToOpenLibrary(panel: .bookmarks)
        
        if sender.accessibilityIdentifier == a11y.MoreButtons.recentlySaved {
            TelemetryWrapper.recordEvent(category: .action,
                                         method: .tap,
                                         object: .firefoxHomepage,
                                         value: .recentlySavedSectionShowAll,
                                         extras: TelemetryWrapper.getOriginExtras(isZeroSearch: viewModel.isZeroSearch))
        }
    }
    
    func openHistory(_ sender: UIButton) {
        homePanelDelegate?.homePanelDidRequestToOpenLibrary(panel: .history)
        
        if sender.accessibilityIdentifier == a11y.MoreButtons.historyHighlights {
            TelemetryWrapper.recordEvent(category: .action,
                                         method: .tap,
                                         object: .firefoxHomepage,
                                         value: .historyHighlightsShowAll)
        }
    }
    
    func openCustomizeHomeSettings() {
        homePanelDelegate?.homePanelDidRequestToOpenSettings(at: .customizeHomepage)
        TelemetryWrapper.recordEvent(category: .action,
                                     method: .tap,
                                     object: .firefoxHomepage,
                                     value: .customizeHomepageButton)
    }
    
    func contextualHintPresented(type: ContextualHintType) {
        homePanelDelegate?.homePanelDidPresentContextualHintOf(type: type)
    }
    
    func openTabsSettings() {
        homePanelDelegate?.homePanelDidRequestToOpenSettings(at: .customizeTabs)
    }
    
    func getPopoverSourceRect(sourceView: UIView?) -> CGRect {
        let cellRect = sourceView?.frame ?? .zero
        let cellFrameInSuperview = self.searchPageView.convert(cellRect, to: self.searchPageView)
        
        return CGRect(origin: CGPoint(x: cellFrameInSuperview.size.width / 2,
                                      y: cellFrameInSuperview.height / 2),
                      size: .zero)
    }
}

// MARK: FirefoxHomeContextMenuHelperDelegate
extension HomepageViewController: HomepageContextMenuHelperDelegate {
    func homePanelDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool, selectNewTab: Bool) {
        homePanelDelegate?.homePanelDidRequestToOpenInNewTab(url, isPrivate: isPrivate, selectNewTab: selectNewTab)
    }
    
    func homePanelDidRequestToOpenSettings(at settingsPage: AppSettingsDeeplinkOption) {
        homePanelDelegate?.homePanelDidRequestToOpenSettings(at: settingsPage)
    }
    
    func showToast(message: String) {
        SimpleToast().showAlertWithText(message, bottomContainer: view, theme: themeManager.currentTheme)
    }
}

// MARK: - Status Bar Background
extension HomepageViewController: SearchBarLocationProvider {}

extension HomepageViewController {
    var statusBarFrame: CGRect? {
        guard let keyWindow = UIWindow.keyWindow else { return nil }
        
        return keyWindow.windowScene?.statusBarManager?.statusBarFrame
    }
    
    // Returns a value between 0 and 1 which indicates how far the user has scrolled.
    // This is used as the alpha of the status bar background.
    // 0 = no status bar background shown
    // 1 = status bar background is opaque
    var scrollOffset: CGFloat {
        // Status bar height can be 0 on iPhone in landscape mode.
        guard isBottomSearchBar,
              let statusBarHeight: CGFloat = statusBarFrame?.height,
              statusBarHeight > 0
        else { return 0 }
        
        // The scrollview content offset is automatically adjusted to account for the status bar.
        // We want to start showing the status bar background as soon as the user scrolls.
        var offset = (self.searchPageView.getOffsetY() + statusBarHeight) / statusBarHeight
        
        if offset > 1 {
            offset = 1
        } else if offset < 0 {
            offset = 0
        }
        return offset
    }
    
    func updateStatusBar(theme: Theme) {
        switch theme.type {
        case .dark:
            let backgroundColor = UIColor.darkBackground
            statusBarView.backgroundColor = backgroundColor.withAlphaComponent(scrollOffset)
            
        case .light:
            let backgroundColor = theme.colors.layer1
            statusBarView.backgroundColor = backgroundColor.withAlphaComponent(scrollOffset)
        }
        
        if let statusBarFrame = statusBarFrame {
            statusBarView.frame = statusBarFrame
        }
    }
}

// MARK: - Popover Presentation Delegate

extension HomepageViewController: UIPopoverPresentationControllerDelegate {
    // Dismiss the popover if the device is being rotated.
    // This is used by the Share UIActivityViewController action sheet on iPad
    func popoverPresentationController(
        _ popoverPresentationController: UIPopoverPresentationController,
        willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>,
        in view: AutoreleasingUnsafeMutablePointer<UIView>
    ) {
        // Do not dismiss if the popover is a CFR
        guard !jumpBackInContextualHintViewController.isPresenting &&
                !syncTabContextualHintViewController.isPresenting else { return }
        popoverPresentationController.presentedViewController.dismiss(animated: false, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return true
    }
}

// MARK: FirefoxHomeViewModelDelegate
extension HomepageViewController: HomepageViewModelDelegate {
    func reloadView() {
        ensureMainThread { [weak self] in
            guard let self = self else { return }
            
            self.viewModel.refreshData(for: self.traitCollection, size: self.view.frame.size)
            self.searchPageView.reloadData()
        }
    }
}

// MARK: FreespokeHomepageViewDelegate
extension HomepageViewController: FreespokeHomepageDelegate {
    func didPressBookmarks() {
        delegate?.didPressBookmarks()
    }
    
    func didPressRecentlyViewed() {
        delegate?.didPressRecentlyViewed()
    }
    
    func didPressSearch() {
        delegate?.didPressSearch()
    }
    
    func didPressMicrophone() {
        delegate?.didPressMicrophone()
    }
    
    func showURL(url: String) {
        delegate?.showURL(url: url)
    }
    
    func didPressShare(_ button: UIButton, url: URL) {
        let helper = ShareExtensionHelper(url: url, tab: nil)
        let controller = helper.createActivityViewController({ completed, activityType in
        })
        
        if let popoverPresentationController = controller.popoverPresentationController {
            popoverPresentationController.sourceView = button
            popoverPresentationController.sourceRect = button.bounds
            popoverPresentationController.permittedArrowDirections = [.up, .down]
            //popoverPresentationController.delegate = self
        }

        self.present(controller, animated: true, completion: nil)
    }
}

// MARK: Subscribe Notifications

extension HomepageViewController {
    private func subscribeNotifications() {
        self.setupNotifications(forObserver: self,
                                observing: [.HomePanelPrefsChanged,
                                            .TabsPrivacyModeChanged,
                                            .WallpaperDidChange,
                                            .freespokeUserAuthChanged])
    }
}

// MARK: - Notifiable
extension HomepageViewController: Notifiable {
    func handleNotifications(_ notification: Notification) {
        ensureMainThread { [weak self] in
            guard let self = self else { return }
            switch notification.name {
            case .TabsPrivacyModeChanged:
                self.adjustPrivacySensitiveSections(notification: notification)
                
            case .HomePanelPrefsChanged,
                    .WallpaperDidChange:
                self.reloadView()
                
            case .freespokeUserAuthChanged:
                self.freespokeHomepageView.updateView(decodedJWTToken: AppSessionManager.shared.decodedJWTToken)
                
            default:
                break
            }
        }
    }
}
