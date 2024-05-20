// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit

// MARK: - Environment

enum FreespokeEnvironment {
    case production
    case staging
    case development
    
    static var current: FreespokeEnvironment {
#if STAGING
        return .staging
#elseif DEVELOPMENT
        return .development
#else
        return .production
#endif
    }
}

enum MenuCellType: String {
    case addAsDefault       = "Add as Default Browser"
    case shareFreespoke     = "Share Freespoke"
    case freespokeBlog      = "Freespoke Blog"
    case ourNewsletters     = "Our Newsletters"
    case getInTouch         = "Get in Touch"
    case appSettings        = "App Settings"
    case bookmars           = "Bookmarks"
}

enum SocialType: String {
    case twitter        = "Twitter"
    case linkedin       = "Linkedin"
    case instagram      = "instagram"
    case facebook       = "facebook"
}

enum MenuCellImageType: String {
    case addAsDefault       = "add-default-dark"
    case shareFreespoke     = "share-dark-menu"
    case freespokeBlog      = "blog-dark"
    case ourNewsletters     = "newsletters-dark"
    case getInTouch         = "get-in-touch-dark"
    case appSettings        = "settings-dark"
    case bookmars           = "bookmars-dark"
}

enum Constants: String {
    // MARK: Drawing Constants
    
    enum DrawingSizes {
        static let profileAvatarSize: CGFloat = 40
        // dynamic width value
        static let iPadContentWidthFactorPortrait = 0.75
        static let iPadContentWidthFactorLandscape = 0.55
        // hardcoded width value
        static let iPadContentWidthStaticValue: CGFloat = 480
    }
    
    enum EasyListsURL {
        static let easyList = "https://easylist.to/easylist/easylist.txt"
        static let easyPrivacyList = "https://easylist.to/easylist/easyprivacy.txt"
        static let easyFanboyAnnoyance = "https://secure.fanboy.co.nz/fanboy-annoyance.txt"
    }
    
    // MARK: - URLs
    enum AppInternalBrowserURLs {
        static var accountProfileURL: String {
            switch FreespokeEnvironment.current {
            case .production:
                let originUrl = "https://freespoke.com/account/profile"
                let modifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: originUrl)
                return modifiedUrl
            case .staging, .development:
                let originUrl = "https://staging.freespoke.com/account/profile"
                let modifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: originUrl)
                return modifiedUrl
            }
        }
        
        static var newsURL: String {
            switch FreespokeEnvironment.current {
            case .production:
                let newsOriginUrl = "https://freespoke.com/news"
                let newsModifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: newsOriginUrl)
                return newsModifiedUrl
            case .staging, .development:
                let newsOriginUrl = "https://staging.freespoke.com/news"
                let newsModifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: newsOriginUrl)
                return newsModifiedUrl
            }
        }
        
        static var electionURL: String {
            switch FreespokeEnvironment.current {
            case .production:
                let originUrl = "https://freespoke.com/election/2024"
                let modifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: originUrl)
                return modifiedUrl
            case .staging, .development:
                let originUrl = "https://staging.freespoke.com/election/2024"
                let modifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: originUrl)
                return modifiedUrl
            }
        }
        
        static var viewMoreTrendingNewsURL: String {
            switch FreespokeEnvironment.current {
            case .production:
                let viewMoreTrendingNewsOriginUrl = "https://freespoke.com/news/what-is-hot"
                let viewMoreTrendingNewsModifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: viewMoreTrendingNewsOriginUrl)
                return viewMoreTrendingNewsModifiedUrl
            case .staging, .development:
                let viewMoreTrendingNewsOriginUrl = "https://staging.freespoke.com/news/what-is-hot"
                let viewMoreTrendingNewsModifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: viewMoreTrendingNewsOriginUrl)
                return viewMoreTrendingNewsModifiedUrl
            }
        }
        
        static var viewMoreShopsURL: String {
            switch FreespokeEnvironment.current {
            case .production:
                let viewMoreShopsOriginUrl = "https://freespoke.com/shop"
                let viewMoreShopsModifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: viewMoreShopsOriginUrl)
                return viewMoreShopsModifiedUrl
            case .staging, .development:
                let viewMoreShopsOriginUrl = "https://staging.freespoke.com/shop"
                let viewMoreShopsModifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: viewMoreShopsOriginUrl)
                return viewMoreShopsModifiedUrl
            }
        }
        
        static var aboutFreespokeURL: String {
            switch FreespokeEnvironment.current {
            case .production:
                let originUrl = "https://freespoke.com/about"
                let modifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: originUrl)
                return modifiedUrl
            case .staging, .development:
                let originUrl = "https://staging.freespoke.com/about"
                let modifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: originUrl)
                return modifiedUrl
            }
        }
        
        static var termsOfServiceURL: String {
            switch FreespokeEnvironment.current {
            case .production:
                let originUrl = "https://freespoke.com/terms-of-service"
                let modifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: originUrl)
                return modifiedUrl
            case .staging, .development:
                let originUrl = "https://staging.freespoke.com/terms-of-service"
                let modifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: originUrl)
                return modifiedUrl
            }
        }
        
        static var privacyPolicyURL: String {
            switch FreespokeEnvironment.current {
            case .production:
                let originUrl = "https://freespoke.com/privacy-policy"
                let modifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: originUrl)
                return modifiedUrl
            case .staging, .development:
                let originUrl = "https://staging.freespoke.com/privacy-policy"
                let modifiedUrl = AnalyticsManager.UTM.addUtmQuery(.sourceFreespokeApp, for: originUrl)
                return modifiedUrl
            }
        }
    }
    
    static var freespokeURL: String {
        switch FreespokeEnvironment.current {
        case .production:
            return "https://freespoke.com/"
        case .staging, .development:
            return "https://staging.freespoke.com/"
        }
    }
    
    case twitterURL = "https://twitter.com/FreespokeSearch/"
    case linkedinURL = "https://www.linkedin.com/company/freespoke-search/"
    case instagramURL = "https://www.instagram.com/freespokesearch/"
    case facebookURL = "https://www.facebook.com/FreespokeSearch"
    case freespokeBlogURL = "https://freespoke.substack.com/"
    case ourNewslettersURL = "https://about.freespoke.com/SignUp"
    case freespokePremiumURL = "https://subscriptions.freespoke.com/signup"
    case getInTouchURL = "https://freespoke-support.freshdesk.com/support/tickets/new"
    
    static var shopURL: String {
        switch FreespokeEnvironment.current {
        case .production:
            return "https://freespoke.com/products"
        case .staging, .development:
            return "https://staging.freespoke.com/products"
        }
    }
    
    case githubiOSURL = "https://github.com/Freespoke/freespoke-browser-ios"
    
    case appleNativeSubscriptions = "itms-apps://apps.apple.com/account/subscriptions" // "https://apps.apple.com/account/subscriptions"
    
    // MARK: - One Signal
    enum OneSignalConstants {
        static var oneSignalId: String {
            switch FreespokeEnvironment.current {
            case .production:
                return "8c38e904-be26-4ed0-9343-4186ab6c7f82"
            case .staging, .development:
                return "de8ebc15-f8ef-427a-b1c1-f312ce831eea"
            }
        }
    }
}

extension UIColor {
    static let redHomeToolbar = Utils.hexStringToUIColor(hex: "C43351")
    static let inactiveToolbar = Utils.hexStringToUIColor(hex: "9AA2B2")
    static let blackColor = Utils.hexStringToUIColor(hex: "2F3644")
    static let whiteColor = Utils.hexStringToUIColor(hex: "E1E5EB")
    static let lightGray = Utils.hexStringToUIColor(hex: "B5BCC9")
    static let darkBackground = Utils.hexStringToUIColor(hex: "161616")
    static let gray7 = Utils.hexStringToUIColor(hex: "F8F9FB")
    static let gray2 = Utils.hexStringToUIColor(hex: "606671")
    static let onboardingDark = Utils.hexStringToUIColor(hex: "#1D1D1D")
    static let onboardingTitleDark = Utils.hexStringToUIColor(hex: "#081A33")
    static let greenColor = Utils.hexStringToUIColor(hex: "#149590")
    static let lavenderGreyColor = Utils.hexStringToUIColor(hex: "#E6E8EF")
    static let neutralsGray5 = Utils.hexStringToUIColor(hex: "#E1E5EB")
    static let blackFS = Utils.hexStringToUIColor(hex: "#E1E5EB")
    static let neutralsGray06 = Utils.hexStringToUIColor(hex: "#EDF0F5")
    static let neutralsGray01 = Utils.hexStringToUIColor(hex: "#2F3644")
    static let neutralsGray05 = Utils.hexStringToUIColor(hex: "#E1E5EB")
    static let charcoalGrayColor = Utils.hexStringToUIColor(hex: "#292929")
    static let gunmetalGrayColor = Utils.hexStringToUIColor(hex: "#525252")
    static let fxOffWhite1 = Utils.hexStringToUIColor(hex: "#DADEE3")
}

class Utils {
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
