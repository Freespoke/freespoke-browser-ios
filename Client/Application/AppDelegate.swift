// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Shared
import Storage
import CoreSpotlight
import UIKit
import Common
import OneSignal
import BranchSDK
import MatomoTracker

class AppDelegate: UIResponder, UIApplicationDelegate {
    let logger = DefaultLogger.shared
    var notificationCenter: NotificationProtocol = NotificationCenter.default
    var orientationLock = UIInterfaceOrientationMask.all
    
    lazy var profile: Profile = BrowserProfile(
        localName: "profile",
        syncDelegate: UIApplication.shared.syncDelegate
    )
    lazy var tabManager: TabManager = TabManager(
        profile: profile,
        imageStore: DiskImageStore(
            files: profile.files,
            namespace: "TabManagerScreenshots",
            quality: UIConstants.ScreenshotQuality)
    )
    
    lazy var themeManager: ThemeManager = DefaultThemeManager()
    lazy var ratingPromptManager = RatingPromptManager(profile: profile)
    
    private var shutdownWebServer: DispatchSourceTimer?
    private var webServerUtil: WebServerUtil?
    private var appLaunchUtil: AppLaunchUtil?
    private var backgroundSyncUtil: BackgroundSyncUtil?
    private var widgetManager: TopSitesWidgetManager?
    private var menuBuilderHelper: MenuBuilderHelper?
    
    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        self.refreshFreespokeTokenIfPossible()
        InAppManager.shared.requestProductsInfo()
        
        // Configure app information for BrowserKit, needed for logger
        BrowserKitInformation.shared.configure(buildChannel: AppConstants.buildChannel,
                                               nightlyAppVersion: AppConstants.nightlyAppVersion,
                                               sharedContainerIdentifier: AppInfo.sharedContainerIdentifier)
        
        // Configure logger so we can start tracking logs early
        logger.configure(crashManager: DefaultCrashManager())
        logger.log("willFinishLaunchingWithOptions begin",
                   level: .info,
                   category: .lifecycle)
        
        // Then setup dependency container as it's needed for everything else
        DependencyHelper().bootstrapDependencies()
        
        appLaunchUtil = AppLaunchUtil(profile: profile)
        appLaunchUtil?.setUpPreLaunchDependencies()
        
        // Set up a web server that serves us static content. Do this early so that it is ready when the UI is presented.
        webServerUtil = WebServerUtil(profile: profile)
        webServerUtil?.setUpWebServer()
        
        menuBuilderHelper = MenuBuilderHelper()
        
        logger.log("willFinishLaunchingWithOptions end",
                   level: .info,
                   category: .lifecycle)
//        Task {
//            await InAppManager.shared.refreshPurchasedProducts()
//        }
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        logger.log("didFinishLaunchingWithOptions start",
                   level: .info,
                   category: .lifecycle)
        
        // Branch init
        self.setupBranchSDK(launchOptions: launchOptions)
        
        self.setupOneSignal(with: launchOptions)
        
        // pushNotificationSetup()
        appLaunchUtil?.setUpPostLaunchDependencies()
        backgroundSyncUtil = BackgroundSyncUtil(profile: profile, application: application)
        
        // Widgets are available on iOS 14 and up only.
        if #available(iOS 14.0, *) {
            let topSitesProvider = TopSitesProviderImplementation(
                placesFetcher: profile.places,
                pinnedSiteFetcher: profile.pinnedSites,
                prefs: profile.prefs
            )
            
            widgetManager = TopSitesWidgetManager(topSitesProvider: topSitesProvider)
        }
        
        addObservers()
        
        logger.log("didFinishLaunchingWithOptions end",
                   level: .info,
                   category: .lifecycle)
        
        FeatureFlagsManager.shared.set(feature: .startAtHome, to: Client.StartAtHomeSetting.afterFourHours)
        FeatureFlagsManager.shared.set(feature: .searchBarPosition, to: SearchBarPosition.bottom)
        
        // Change homepage & new tab configurations from scope 2.0.0
        profile.prefs.setString("", forKey: PrefsKeys.HomeButtonHomePageURL)
        profile.prefs.setString("", forKey: PrefsKeys.KeyDefaultHomePageURL)
        profile.prefs.setString(NewTabPage.topSites.rawValue, forKey: NewTabAccessors.HomePrefKey)
        
        if UserDefaults.standard.string(forKey: NimbusFeatureFlagIsSet.searchBarPosition.rawValue) == nil {
            FeatureFlagsManager.shared.set(feature: .searchBarPosition, to: SearchBarPosition.bottom)
            
            UserDefaults.standard.set(NimbusFeatureFlagIsSet.searchBarPosition.rawValue, forKey: NimbusFeatureFlagIsSet.searchBarPosition.rawValue)
        }
        
        if UserDefaults.standard.string(forKey: NimbusFeatureFlagIsSet.jumpBackIn.rawValue) == nil {
            let jumpBackIn = NimbusFlaggableFeature(withID: .jumpBackIn, and: profile)
            jumpBackIn.setUserPreference(to: false)
            
            UserDefaults.standard.set(NimbusFeatureFlagIsSet.jumpBackIn.rawValue, forKey: NimbusFeatureFlagIsSet.jumpBackIn.rawValue)
        }
        
        if UserDefaults.standard.string(forKey: NimbusFeatureFlagIsSet.sponsoredTiles.rawValue) == nil {
            let sponsoredTiles = NimbusFlaggableFeature(withID: .sponsoredTiles, and: profile)
            sponsoredTiles.setUserPreference(to: false)
            
            UserDefaults.standard.set(NimbusFeatureFlagIsSet.sponsoredTiles.rawValue, forKey: NimbusFeatureFlagIsSet.sponsoredTiles.rawValue)
        }
        
        // Matomo tracker
        MatomoTracker.shared.isOptedOut = false
        
        AnalyticsManager.trackMatomoEvent(category: .appEntry,
                                          action: AnalyticsManager.MatomoAction.appEntryAction.rawValue,
                                          name: AnalyticsManager.MatomoName.open)
        
        return true
    }
    
    private func refreshFreespokeTokenIfPossible() {
        if let refreshToken = Keychain.authInfo?.refreshToken {
            AppSessionManager.shared.performRefreshFreespokeToken(completion: nil)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Handler for Universal Links
        Branch.getInstance().continue(userActivity)
        return true
    }
    
    // We sync in the foreground only, to avoid the possibility of runaway resource usage.
    // Eventually we'll sync in response to notifications.
    func applicationDidBecomeActive(_ application: UIApplication) {
        logger.log("applicationDidBecomeActive start",
                   level: .info,
                   category: .lifecycle)
        
        shutdownWebServer?.cancel()
        shutdownWebServer = nil
        
        profile.reopen()
        
        if profile.prefs.boolForKey(PendingAccountDisconnectedKey) ?? false {
            profile.removeAccount()
        }
        
        profile.syncManager.applicationDidBecomeActive()
        webServerUtil?.setUpWebServer()
        
        TelemetryWrapper.recordEvent(category: .action, method: .foreground, object: .app)
        
        // update top sites widget
        updateTopSitesWidget()
        
        // Cleanup can be a heavy operation, take it out of the startup path. Instead check after a few seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.profile.cleanupHistoryIfNeeded()
            self?.ratingPromptManager.updateData()
        }
        
        logger.log("applicationDidBecomeActive end",
                   level: .info,
                   category: .lifecycle)
        AdBlockManager.shared.updateEasyListIfNeeded(completion: nil)

    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        updateTopSitesWidget()
        
        UserDefaults.standard.setValue(Date(), forKey: "LastActiveTimestamp")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        logger.log("applicationDidEnterBackground start",
                   level: .info,
                   category: .lifecycle)
        
        TelemetryWrapper.recordEvent(category: .action, method: .background, object: .app)
        TabsQuantityTelemetry.trackTabsQuantity(tabManager: tabManager)
        
        profile.syncManager.applicationDidEnterBackground()
        
        let singleShotTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        // 2 seconds is ample for a localhost request to be completed by GCDWebServer. <500ms is expected on newer devices.
        singleShotTimer.schedule(deadline: .now() + 2.0, repeating: .never)
        singleShotTimer.setEventHandler {
            WebServer.sharedInstance.server.stop()
            self.shutdownWebServer = nil
        }
        singleShotTimer.resume()
        shutdownWebServer = singleShotTimer
        backgroundSyncUtil?.scheduleSyncOnAppBackground()
        tabManager.preserveTabs()
        
        logger.log("applicationDidEnterBackground end",
                   level: .info,
                   category: .lifecycle)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // We have only five seconds here, so let's hope this doesn't take too long.
        profile.shutdown()
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        logger.log("Received memory warning", level: .info, category: .lifecycle)
    }
    
    private func updateTopSitesWidget() {
        // Since we only need the topSites data in the archiver, let's write it
        // only if iOS 14 is available.
        if #available(iOS 14.0, *) {
            widgetManager?.writeWidgetKitTopSites()
        }
    }
    
    // Look Orientation in some screens for UX
    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        
        /*
         static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
         self.lockOrientation(orientation)
         
         if #available(iOS 16.0, *) {
         let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
         
         windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
         } else {
         UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
         }
         }
         */
    }
}

extension AppDelegate: Notifiable {
    private func addObservers() {
        setupNotifications(forObserver: self, observing: [UIApplication.didBecomeActiveNotification,
                                                          UIApplication.willResignActiveNotification,
                                                          UIApplication.didEnterBackgroundNotification])
    }
    
    /// When migrated to Scenes, these methods aren't called. Consider this a tempoary solution to calling into those methods.
    func handleNotifications(_ notification: Notification) {
        switch notification.name {
        case UIApplication.didBecomeActiveNotification:
            applicationDidBecomeActive(UIApplication.shared)
        case UIApplication.willResignActiveNotification:
            applicationWillResignActive(UIApplication.shared)
        case UIApplication.didEnterBackgroundNotification:
            applicationDidEnterBackground(UIApplication.shared)
            
        default: break
        }
    }
}

// This functionality will need to be moved to the SceneDelegate when the time comes
extension AppDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
}

// MARK: - Key Commands

extension AppDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        guard builder.system == .main else { return }
        
        menuBuilderHelper?.mainMenu(for: builder)
    }
}

// MARK: - Scenes related methods
extension AppDelegate {
    /// UIKit is responsible for creating & vending Scene instances. This method is especially useful when there
    /// are multiple scene configurations to choose from.  With this method, we can select a configuration
    /// to create a new scene with dynamically (outside of what's in the pList).
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: connectingSceneSession.configuration.name,
            sessionRole: connectingSceneSession.role
        )
        
        configuration.sceneClass = connectingSceneSession.configuration.sceneClass
        configuration.delegateClass = connectingSceneSession.configuration.delegateClass
        
        return configuration
    }
}

// MARK: - Setup OneSignal

extension AppDelegate {
    private func setupOneSignal(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        
        // Remove this method to stop OneSignal Debugging
//        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
        // OneSignal initialization
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setLaunchURLsInApp(true)
        
        // One Signal Secret Key
        OneSignal.setAppId(Constants.OneSignalConstants.oneSignalId)
        
        //        // Ask for setup notification setting
        //        OneSignal.promptForPushNotifications(userResponse: { accepted in
        //            print("User accepted notification: \(accepted)")
        //        })
        let state = OneSignal.getDeviceState()
        if let userId = state?.userId {
            print("DEBUG: OneSignal Player ID: \(userId)")
            // Save this userId for later use
        } else {
            print("DEBUG: OneSignal No Player ID")
        }
        
    }
}

// MARK: - Setup BranchSDK

extension AppDelegate {
    private func setupBranchSDK(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        switch FreespokeEnvironment.current {
        case .production:
            Branch.setUseTestBranchKey(false)
        case .staging, .development:
            Branch.setUseTestBranchKey(true)
        }
        
        // Call `checkPasteboardOnInstall()` before Branch initialization
        Branch.getInstance().checkPasteboardOnInstall()
        
        // This version of initSession includes the source UIScene in the callback
        BranchScene.shared().initSession(launchOptions: launchOptions, registerDeepLinkHandler: { (params, error, scene) in
            print("DEBUG: setupBranchSDK with params: ", params as? [String: AnyObject] ?? {})
        })
    }
}

// MARK: - MatomoTracker

extension MatomoTracker {
    static let shared: MatomoTracker = MatomoTracker(siteId: AnalyticsManager.Matomo.matomoSiteId,
                                                     baseURL: URL(string: AnalyticsManager.Matomo.baseURL)!)
}
