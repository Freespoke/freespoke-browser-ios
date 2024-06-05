// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import MatomoTracker

extension AnalyticsManager {
    enum Matomo {
        static var baseURL: String {
            return "https://matomo.freespoke.com/matomo.php"
        }
        
        static var matomoSiteId: String {
            switch FreespokeEnvironment.current {
            case .production:
                return "6"
            case .staging, .development:
                return "7"
            }
        }
    }
    
    // MARK: - Matomo Category
    
    enum MatomoCategory: String {
        case appEntry           = "app entry"
        case appMenuCategory    = "app menu"
        case appHomeCategory    = "app home"
        case appTabs            = "app tabs"
        case appShareCategory   = "app share"
        case appOnboardCategory = "app onboard"
        case appProfileCategory = "app profile"
    }
    
    // MARK: - Matomo Name
    
    struct MatomoName {
        static let open       = "open"
        static let clickName  = "click"
        static let search     = "search"
    }
    
    // MARK: - Matomo Action
    
    enum MatomoAction: String {
        // app entry
        case appEntryAction      = "app entry"							// Int001
        
        // app menu
        case appMenuTab          = "app menu tab click - "							// menu001
        case appMenuMakeDefaultBrowserClick = "app menu make default browser click"	// menu002
        case appManageNotificationsClick = "app manage notifications click" 		// menu003
        
        // subscription, manage plan
        case appManageUpdatePlanClickAction = "app manage update plan click"		// menu005
        case appManageСancelPlanClickAction = "app manage cancel plan click"		// menu006
        
        // app home actions
        case appHomeSearch                   = "app home search"									// home001
        case appHomeBookmarks                = "app home my bookmarks click"						// home002
        case appHomeTrendingNewsStoryViewMoreClick = "app home trending news story view more click"	// home003
        case appHomeRecently                 = "app home recently viewed click"						// home004
        case appHomeShopUsaClick             = "app home shop usa click"							// home005
        case appHomeFreespoke                = "app home the freespoke way click - "				// home006
        case appHomeBreakingNewsStoryViewAllClick = "app home breaking news story view all click"
        
        case appHomeTrendingNewsStoryClick   = "app home trending news story click"					// home0041
        case appHomeShopUsaViewMoreClick     = "app home shop usa view more click"					// home0051
        
        // app tabs
        case appTabsCloseTabsMenu   = "app tabs close tabs menu"		// Tabs001
        case appTabsNewTab          = "app tabs new tab click" 			// Tabs002
        case appTabsCloseAllTabs    = "app tabs close all tabs click"	// Tabs003
        case appTabsPrivateBrowsing = "app tabs private browsing click"	// Tabs004
        case appTabsRegularBrowsing = "app tabs regular browsing click"	// Tabs005
        
        // app share
        case appShareMenuAction            = "app share from menu"			// share001
        case appWebWrapperShareAction      = "app web wrapper share"		// share002
        case appShareFromProfileMenuAction = "app share from profile menu"	// share003
        
        // app profile
        case appProfileHomePageAvatarClickedAction  = "app profile avatar clicked to open profile menu" // profile001
        case appProfileScreenAction                 = "app profile click - " 							// profile002
        
        // app onboard actions
        case appOnbCloseClickAction = "app onboard close click"																		// ob001
        case appOnbWithoutAccClickAction = "app onboard continue without an account click"											// ob002
        case appOnbWithoutAccSetAsDefBrowserClickAction = "app onboard continue without an account set as default browser click"	// ob003
        case appOnbWithoutAccAllowNotificationsClickAction = "app onboard continue without an account allow notifications click"	// ob004
        case appOnbCreateAccClickAction = "app onboard create account click"														// ob005
        case appOnbCreateAccContinueWithoutPremiumClickAction = "app onboard create account continue without premium click"			// ob006
        case appOnbCreateAccPremiumPriceClickAction = "app onboard create account premium price click"								// ob007
        case appOnbCreateAccSetAsDefBrowserClickAction = "app onboard create account an account set as default browser click"		// ob008
        case appOnbCreateAccAllowNotificationsClickAction = "app onboard create account allow notifications click" 					// ob009
    }
}

// MARK: - UTM
extension AnalyticsManager {
    enum UTM {
        case sourceFreespokeApp
        
        // MARK: Keys
        static private var utmSourceKey = "utm_source"
        
        // MARK: Values
        static private var utmFreespokeAppValue = "freespoke_app"
        
        // MARK: Functions
        static func addUtmQuery(_ utm: UTM, for urlString: String) -> String {
            if var urlComponents = URLComponents(string: urlString) {
                var queryItems = [URLQueryItem]()
                let newQueryParam = URLQueryItem(name: "\(AnalyticsManager.UTM.utmSourceKey)",
                                                 value: "\(AnalyticsManager.UTM.utmFreespokeAppValue)")
                if let existingQueryItems = urlComponents.queryItems {
                    if !existingQueryItems.contains(newQueryParam) {
                        queryItems.append(newQueryParam)
                    }
                    queryItems.append(contentsOf: existingQueryItems)
                } else {
                    queryItems.append(newQueryParam)
                }
                
                urlComponents.queryItems = queryItems
                
                // Reconstruct the URL
                if let newURL = urlComponents.url {
                    return newURL.absoluteString
                } else {
                    print("DEBUG: Error: Unable to construct URL with additional query parameters.")
                    return urlString
                }
            } else {
                print("DEBUG: Error: Invalid URL format.")
                return urlString
            }
        }
    }
}
