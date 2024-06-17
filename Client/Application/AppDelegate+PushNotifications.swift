// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import UIKit
import Shared
import Storage
import Sync
import UserNotifications
import Account
import MozillaAppServices

/**
 * This exists because the Sync code is extension-safe, and thus doesn't get
 * direct access to UIApplication.sharedApplication, which it would need to display a notification.
 * This will also likely be the extension point for wipes, resets, and getting access to data sources during a sync.
 */
enum SentTabAction: String {
    case view = "TabSendViewAction"

    static let TabSendURLKey = "TabSendURL"
    static let TabSendTitleKey = "TabSendTitle"
    static let TabSendCategory = "TabSendCategory"

    static func registerActions() {
        let viewAction = UNNotificationAction(identifier: SentTabAction.view.rawValue, title: .SentTabViewActionTitle, options: .foreground)

        // Register ourselves to handle the notification category set by NotificationService for APNS notifications
        let sentTabCategory = UNNotificationCategory(
            identifier: "org.mozilla.ios.SentTab.placeholder",
            actions: [viewAction],
            intentIdentifiers: [],
            options: UNNotificationCategoryOptions(rawValue: 0))
        UNUserNotificationCenter.current().setNotificationCategories([sentTabCategory])
    }
}

extension AppDelegate {
    func pushNotificationSetup() {
       UNUserNotificationCenter.current().delegate = self
       SentTabAction.registerActions()

        NotificationCenter.default.addObserver(forName: .RegisterForPushNotifications, object: nil, queue: .main) { _ in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus != .denied {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }

        // If we see our local device with a pushEndpointExpired flag, clear the APNS token and re-register.
        NotificationCenter.default.addObserver(forName: .constellationStateUpdate, object: nil, queue: nil) { notification in
            if let newState = notification.userInfo?["newState"] as? ConstellationState {
                if newState.localDevice?.pushEndpointExpired ?? false {
                    MZKeychainWrapper.sharedClientAppContainerKeychain.removeObject(forKey: KeychainKey.apnsToken, withAccessibility: MZKeychainItemAccessibility.afterFirstUnlock)
                    NotificationCenter.default.post(name: .RegisterForPushNotifications, object: nil)
                    // Our endpoint expired, we should check for missed messages
                    self.profile.pollCommands(forcePoll: true)
                }
            }
        }

        // Use sync event as a periodic check for the apnsToken.
        // The notification service extension can clear this token if there is an error, and the main app can detect this and re-register.
        NotificationCenter.default.addObserver(forName: .ProfileDidStartSyncing, object: nil, queue: .main) { _ in
            let kc = MZKeychainWrapper.sharedClientAppContainerKeychain
            if kc.string(forKey: KeychainKey.apnsToken, withAccessibility: MZKeychainItemAccessibility.afterFirstUnlock) == nil {
                NotificationCenter.default.post(name: .RegisterForPushNotifications, object: nil)
            }
        }
    }

    private func openURLsInNewTabs(_ notification: UNNotification) {
        var receivedUrlsQueue: [URL] = []

        guard let urls = notification.request.content.userInfo["sentTabs"] as? [NSDictionary]  else { return }
        for sentURL in urls {
            if let urlString = sentURL.value(forKey: "url") as? String, let url = URL(string: urlString) {
                receivedUrlsQueue.append(url)
            }
        }

        // Check if the app is foregrounded
        if UIApplication.shared.applicationState == .active {
            let object = OpenTabNotificationObject(type: .loadQueuedTabs(receivedUrlsQueue))
            NotificationCenter.default.post(name: .OpenTabNotification, object: object)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate Methods

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //  show the notification
        if #available(iOS 14, *) {
            completionHandler([.list, .banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo    = response.notification.request.content.userInfo
        let info        = userInfo as NSDictionary
        
        print("DEBUG: notifications didReceive response \(userInfo)")
        
        if let custom = info["custom"] as? NSDictionary {
            if let url = custom["u"] as? String {
                print(url)
                
                if let url = URL(string: url) {
                    if NotificationManager().notificationHasSilentDeepLink(link: url) {
                        NotificationManager().handleSilentDeepLinkFromPush(url)
                    } else {
                        if UIApplication.shared.applicationState == .active {
                            let object = OpenTabNotificationObject(type: .switchToTabForURLOrOpen(url))
                            NotificationCenter.default.post(name: .OpenTabNotification, object: object)
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                if UIApplication.shared.applicationState == .active {
                                    let object = OpenTabNotificationObject(type: .switchToTabForURLOrOpen(url))
                                    NotificationCenter.default.post(name: .OpenTabNotification, object: object)
                                }
                            }
                        }
                    }
                }
            }
        }

        completionHandler()
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) {
//        let userInfo    = response.notification.request.content.userInfo
//        let info        = userInfo as NSDictionary
//
//        if let custom = info["custom"] as? NSDictionary {
//            if let url = custom["u"] as? String {
//                print(url)
//
//                if let url = URL(string: url) {
//                    if UIApplication.shared.applicationState == .active {
//                        let object = OpenTabNotificationObject(type: .switchToTabForURLOrOpen(url))
//                        NotificationCenter.default.post(name: .OpenTabNotification, object: object)
//                    }
//                    else {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                            let object = OpenTabNotificationObject(type: .switchToTabForURLOrOpen(url))
//                            NotificationCenter.default.post(name: .OpenTabNotification, object: object)
//                        }
//                    }
//                }
//            }
//        }
//    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //RustFirefoxAccounts.shared.pushNotifications.didRegister(withDeviceToken: deviceToken)
        
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        // Print it to console
        
        print("DEBUG: notifications didRegisterForRemoteNotificationsWithDeviceToken deviceToken: ", deviceTokenString)
        print("DEBUG: APNs device token: \(deviceTokenString)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("DEBUG: notifications didFailToRegisterForRemoteNotificationsWithError")
        // Print the error to console (you should alert the user that registration failed)
        print("DEBUG: APNs registration failed: \(error)")
        
        logger.log("Failed to register for APNS",
                   level: .info,
                   category: .setup)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("DEBUG: notifications didReceiveRemoteNotification")
        print("DEBUG: notifications Entire message \(userInfo)")
        completionHandler(.newData)
    }
}
