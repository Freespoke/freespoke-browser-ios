// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Shared
import UIKit

extension BrowserViewController: TabToolbarDelegate, PhotonActionSheetProtocol {
    func tabToolbarDidPressHome(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        
        //|     Reload all items on freespoke home
        if !isHome {
            homepageViewController?.reloadFreespokeHomepage()
        }
        
        userHasPressedHomeButton = true
        isNewTab = false
        isHome = true
        isSearching = false
        
        setValues(isHome: isHome, isNewTab: isNewTab, isSearching: isSearching)
        
        let page = NewTabAccessors.getHomePage(self.profile.prefs)
        
        
        if page == .homePage, let homePageURL = HomeButtonHomePageAccessors.getHomePage(self.profile.prefs) {
            tabManager.selectedTab?.loadRequest(PrivilegedRequest(url: homePageURL) as URLRequest)
        } else if let homePanelURL = page.url {
            tabManager.selectedTab?.loadRequest(PrivilegedRequest(url: homePanelURL) as URLRequest)
        } else if page == .freespoke {
            if let homePanelURL = URL(string: Constants.AppInternalBrowserURLs.freespokeURL) {
                tabManager.selectedTab?.loadRequest(PrivilegedRequest(url: homePanelURL) as URLRequest)
            }
        }
        
        
//        switch page {
//        case .freespoke:
//            tabManager.startAtHomeCheck()
////            if let homePanelURL = URL(string: Constants.AppInternalBrowserURLs.freespokeURL) {
////                tabManager.selectedTab?.loadRequest(PrivilegedRequest(url: homePanelURL) as URLRequest)
////            }
//
//        case .homePage:
//            if let homePageURL = HomeButtonHomePageAccessors.getHomePage(self.profile.prefs) {
//                tabManager.selectedTab?.loadRequest(PrivilegedRequest(url: homePageURL) as URLRequest)
//            }
//
//        case .topSites:
//            tabManager.startAtHomeCheck()
//        }
        
        TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .home)
    }

    func tabToolbarDidPressLibrary(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
    }

    func tabToolbarDidPressReload(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        tabManager.selectedTab?.reload()
    }

    func tabToolbarDidLongPressReload(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        guard let tab = tabManager.selectedTab else { return }

        let urlActions = self.getRefreshLongPressMenu(for: tab)
        guard !urlActions.isEmpty else { return }

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        let shouldSuppress = UIDevice.current.userInterfaceIdiom == .pad
        let style: UIModalPresentationStyle = shouldSuppress ? .popover : .overCurrentContext
        let viewModel = PhotonActionSheetViewModel(actions: [urlActions], closeButtonTitle: .CloseButtonTitle, modalStyle: style)
        presentSheetWith(viewModel: viewModel, on: self, from: button)
    }

    func tabToolbarDidPressStop(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        tabManager.selectedTab?.stop()
    }

    func tabToolbarDidPressBack(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        if button.tag == 1 {
            AnalyticsManager.trackMatomoEvent(category: .appMenuCategory,
                                              action: AnalyticsManager.MatomoAction.appMenuTab.rawValue + "News",
                                              name: AnalyticsManager.MatomoName.clickName)
            
            openLinkURL(Constants.AppInternalBrowserURLs.newsURL)
            
            //urlBar.alpha = 1.0
        }
        else {
            /*
            if !isNewTab {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    urlBar.alpha = 0
                } else {
                    urlBar.alpha = 1.0
                }
            }
            else {
                urlBar.alpha = 1.0
            }
            */
            
            tabManager.selectedTab?.goBack()
        }
    }

    func tabToolbarDidLongPressBack(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        showBackForwardList()
    }
    
    func tabToolbarDidPressElection(_ tabToolbar: any TabToolbarProtocol, button: UIButton) {
        AnalyticsManager.trackMatomoEvent(category: .appMenuCategory,
                                          action: AnalyticsManager.MatomoAction.appMenuTab.rawValue + "Election",
                                          name: AnalyticsManager.MatomoName.clickName)
        
        openLinkURL(Constants.AppInternalBrowserURLs.electionURL)
    }
    
    func tabToolbarDidLongPressElection(_ tabToolbar: any TabToolbarProtocol, button: UIButton) {
        
    }

    func tabToolbarDidPressForward(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        if button.tag == 1 {
            AnalyticsManager.trackMatomoEvent(category: .appMenuCategory,
                                              action: AnalyticsManager.MatomoAction.appMenuTab.rawValue + "Shop",
                                              name: AnalyticsManager.MatomoName.clickName)
            
            openLinkURL(Constants.AppInternalBrowserURLs.viewMoreShopsURL)
        } else {
            /*
            if !isNewTab {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    urlBar.alpha = 0
                } else {
                    urlBar.alpha = 1
                }
            }
            else {
                urlBar.alpha = 1
            }
            */
            
            tabManager.selectedTab?.goForward()
        }
    }

    func tabToolbarDidLongPressForward(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        showBackForwardList()
    }

    func tabToolbarDidPressBookmarks(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        showLibrary(panel: .bookmarks)
    }

    func tabToolbarDidPressAddNewTab(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        let isPrivate = tabManager.selectedTab?.isPrivate ?? false
        tabManager.selectTab(tabManager.addTab(nil, isPrivate: isPrivate))
        focusLocationTextField(forTab: tabManager.selectedTab)
    }

    func tabToolbarDidPressMenu(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        // Ensure that any keyboards or spinners are dismissed before presenting the menu
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        AnalyticsManager.trackMatomoEvent(category: .appMenuCategory,
                                          action: AnalyticsManager.MatomoAction.appMenuTab.rawValue + "Menu",
                                          name: AnalyticsManager.MatomoName.clickName)

        // Logs homePageMenu or siteMenu depending if HomePage is open or not
        let isHomePage = tabManager.selectedTab?.isFxHomeTab ?? false
        let eventObject: TelemetryWrapper.EventObject = isHomePage ? .homePageMenu : .siteMenu
        TelemetryWrapper.recordEvent(category: .action, method: .tap, object: eventObject)
        let menuHelper = MainMenuActionHelper(profile: profile,
                                              tabManager: tabManager,
                                              buttonView: button,
                                              showFXASyncAction: presentSignInViewController)
        menuHelper.delegate = self
        menuHelper.menuActionDelegate = self
        menuHelper.sendToDeviceDelegate = self
        
        menuHelper.getToolbarActions(navigationController: navigationController) { actions in
            let viewModel = PhotonActionSheetViewModel(actions: actions, modalStyle: .popover, isMainMenu: true, isMainMenuInverted: false)
            self.presentSheetWith(viewModel: viewModel, on: self, from: button)
        }
        
        //|     Show Freespoke customized menu
        //showMenuController()
    }
    
    private func showMenuController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MenuController") as! MenuController
        vc.delegate = self
        vc.currentTheme = themeManager.currentTheme
        
        transitionVc(duration: 0.0, type: .fromRight)
        navigationController?.pushViewController(vc, animated: false)
        
        //vc.modalPresentationStyle = .fullScreen
        //vc.modalTransitionStyle = .coverVertical
        //present(vc, animated: false, completion: nil)
    }

    func tabToolbarDidPressTabs(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        AnalyticsManager.trackMatomoEvent(category: .appMenuCategory,
                                          action: AnalyticsManager.MatomoAction.appMenuTab.rawValue + "Tabs",
                                          name: AnalyticsManager.MatomoName.clickName)
        
        let boolBookmarksProfile = profile.prefs.boolForKey("ContextualHintBookmarksLocationKey") ?? false
        
        if boolBookmarksProfile {
            showTabTray()
            TelemetryWrapper.recordEvent(category: .action, method: .press, object: .tabToolbar, value: .tabView)
        }
        else {
            showBookamrksAlert()
        }
    }

    func getTabToolbarLongPressActionsForModeSwitching() -> [PhotonRowActions] {
        guard let selectedTab = tabManager.selectedTab else { return [] }
        let count = selectedTab.isPrivate ? tabManager.normalTabs.count : tabManager.privateTabs.count
        let infinity = "\u{221E}"
        let tabCount = (count < 100) ? count.description : infinity

        func action() {
            let result = tabManager.switchPrivacyMode()
            if result == .createdNewTab, NewTabAccessors.getNewTabPage(self.profile.prefs) == .freespoke {
                focusLocationTextField(forTab: tabManager.selectedTab)
            }
        }

        let privateBrowsingMode = SingleActionViewModel(title: .KeyboardShortcuts.PrivateBrowsingMode,
                                                        iconString: "nav-tabcounter",
                                                        iconType: .TabsButton,
                                                        tabCount: tabCount) { _ in
            action()
        }.items

        let normalBrowsingMode = SingleActionViewModel(title: .KeyboardShortcuts.NormalBrowsingMode,
                                                       iconString: "nav-tabcounter",
                                                       iconType: .TabsButton,
                                                       tabCount: tabCount) { _ in
            action()
        }.items

        if let tab = self.tabManager.selectedTab {
            return tab.isPrivate ? [normalBrowsingMode] : [privateBrowsingMode]
        }
        return [privateBrowsingMode]
    }

    func getMoreTabToolbarLongPressActions() -> [PhotonRowActions] {
        let newTab = SingleActionViewModel(title: .KeyboardShortcuts.NewTab, iconString: ImageIdentifiers.newTab, iconType: .Image) { _ in
            let shouldFocusLocationField = NewTabAccessors.getNewTabPage(self.profile.prefs) == .freespoke
            self.openBlankNewTab(focusLocationField: shouldFocusLocationField, isPrivate: false)
        }.items

        let newPrivateTab = SingleActionViewModel(title: .KeyboardShortcuts.NewPrivateTab, iconString: ImageIdentifiers.newTab, iconType: .Image) { _ in
            let shouldFocusLocationField = NewTabAccessors.getNewTabPage(self.profile.prefs) == .freespoke
            self.openBlankNewTab(focusLocationField: shouldFocusLocationField, isPrivate: true)
        }.items

        let closeTab = SingleActionViewModel(title: .KeyboardShortcuts.CloseCurrentTab, iconString: "tab_close", iconType: .Image) { _ in
            if let tab = self.tabManager.selectedTab {
                self.tabManager.removeTab(tab)
                self.updateTabCountUsingTabManager(self.tabManager)
            }
        }.items

        if let tab = self.tabManager.selectedTab {
            return tab.isPrivate ? [newPrivateTab, closeTab] : [newTab, closeTab]
        }
        return [newTab, closeTab]
    }

    func tabToolbarDidLongPressTabs(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        guard self.presentedViewController == nil else { return }
        var actions: [[PhotonRowActions]] = []
        actions.append(getTabToolbarLongPressActionsForModeSwitching())
        actions.append(getMoreTabToolbarLongPressActions())

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        let viewModel = PhotonActionSheetViewModel(actions: actions, closeButtonTitle: .CloseButtonTitle, modalStyle: .overCurrentContext)
        presentSheetWith(viewModel: viewModel, on: self, from: button)
    }

    func showBackForwardList() {
        if let backForwardList = tabManager.selectedTab?.webView?.backForwardList {
            let backForwardViewController = BackForwardListViewController(profile: profile, backForwardList: backForwardList)
            backForwardViewController.tabManager = tabManager
            backForwardViewController.bvc = self
            backForwardViewController.modalPresentationStyle = .overCurrentContext
            backForwardViewController.backForwardTransitionDelegate = BackForwardListAnimator()
            self.present(backForwardViewController, animated: true, completion: nil)
        }
    }

    func tabToolbarDidPressSearch(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        focusLocationTextField(forTab: tabManager.selectedTab)
    }
}

// MARK: - MenuControllerDelegate Methods
extension BrowserViewController: MenuControllerDelegate {
    func didSelectOption(curCellType: MenuCellType) {
        switch curCellType {
        case .freespokeBlog:
            openLinkURL(Constants.freespokeBlogURL.rawValue)
            
        case .ourNewsletters:
            openLinkURL(Constants.ourNewslettersURL.rawValue)
            
        case .getInTouch:
            openLinkURL(Constants.getInTouchURL.rawValue)
            
        case .appSettings:
            showSettingsScreen()
            
        case .bookmars:
            showLibrary(panel: .bookmarks)
            
        default:
            break
        }
    }
    
    func didSelectSocial(socialType: SocialType) {
        switch socialType {
        case .twitter:
            openLinkURL(Constants.twitterURL.rawValue)
            
        case .linkedin:
            openLinkURL(Constants.linkedinURL.rawValue)
            
        case .instagram:
            openLinkURL(Constants.instagramURL.rawValue)
            
        case .facebook:
            openLinkURL(Constants.facebookURL.rawValue)
        }
    }
    
    // MARK: Custom Methods
    
    func openLinkURL(_ strUrl: String) {
        if let url = URL(string: strUrl) {
            tabManager.selectedTab?.loadRequest(PrivilegedRequest(url: url) as URLRequest)
        }
    }
    
    private func showSettingsScreen() {
        let settingsTableViewController = AppSettingsTableViewController(
            with: self.profile,
            and: self.tabManager,
            delegate: self)

        let controller = ThemedNavigationController(rootViewController: settingsTableViewController)
        // On iPhone iOS13 the WKWebview crashes while presenting file picker if its not full screen. Ref #6232
        if UIDevice.current.userInterfaceIdiom == .phone {
            controller.modalPresentationStyle = .fullScreen
        }
        //controller.presentingModalViewControllerDelegate = self.menuActionDelegate
        TelemetryWrapper.recordEvent(category: .action, method: .open, object: .settings)

        // Wait to present VC in an async dispatch queue to prevent a case where dismissal
        // of this popover on iPad seems to block the presentation of the modal VC.
        DispatchQueue.main.async {
            self.showViewController(viewController: controller)
        }
    }
}

// MARK: - ToolbarActionMenuDelegate
extension BrowserViewController: ToolBarActionMenuDelegate {
    func showFreespokeProfile() {
        self.homepageViewController?.displayFreefolkProfileVC()
    }
    
    func updateToolbarState() {
        updateToolbarStateForTraitCollection(view.traitCollection)
    }

    func showViewController(viewController: UIViewController) {
        presentWithModalDismissIfNeeded(viewController, animated: true)
    }

    func showToast(message: String, toastAction: MenuButtonToastAction, url: String?) {
        switch toastAction {
        case .removeBookmark:
            let viewModel = ButtonToastViewModel(labelText: message,
                                                 buttonText: .UndoString,
                                                 textAlignment: .left)
            let toast = ButtonToast(viewModel: viewModel,
                                    theme: themeManager.currentTheme) { isButtonTapped in
                isButtonTapped ? self.addBookmark(url: url ?? "") : nil
            }
            show(toast: toast)
        default:
            SimpleToast().showAlertWithText(message,
                                            bottomContainer: webViewContainer,
                                            theme: themeManager.currentTheme)
        }
    }

    func showMenuPresenter(url: URL, tab: Tab, view: UIView) {
        presentActivityViewController(url, tab: tab, sourceView: view, sourceRect: view.bounds, arrowDirection: .up)
    }

    func showFindInPage() {
        updateFindInPageVisibility(visible: true)
    }

    func showCustomizeHomePage() {
        showSettingsWithDeeplink(to: .customizeHomepage)
    }

    func showWallpaperSettings() {
        showSettingsWithDeeplink(to: .wallpaper)
    }

    func showDeviceSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
    }
}

extension UIViewController {
    func transitionVc(duration: CFTimeInterval, type: CATransitionSubtype) {
        let transition = CATransition()
        transition.duration = duration
        transition.type = CATransitionType.reveal
        transition.subtype = type
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        //present(customVcTransition, animated: false, completion: nil)
    }
}
