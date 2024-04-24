// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit

// MARK: - Environment

enum FreespokeEnvironment {
    case production
    case staging
    
    static var current: FreespokeEnvironment {
#if STAGING
        return .staging
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
        static let iPadContentWidthFactorPortrait = 0.75
        static let iPadContentWidthFactorLandscape = 0.55
    }
    
    static var apiBaseURL: String {
        switch FreespokeEnvironment.current {
        case .production:
            return "https://api.freespoke.com/v2"
        case .staging:
            return "https://api.staging.freespoke.com/v2"
        }
    }
    
    // MARK: - URLs
    
    enum URLs {
        static var accountProfileURL: String {
            switch FreespokeEnvironment.current {
            case .production:
                return "https://freespoke.com/account/profile"
            case .staging:
                return "https://staging.freespoke.com/account/profile"
            }
        }
    }
    
    case freespokeURL = "https://freespoke.com/"
    case twitterURL = "https://twitter.com/FreespokeSearch/"
    case linkedinURL = "https://www.linkedin.com/company/freespoke-search/"
    case instagramURL = "https://www.instagram.com/freespokesearch/"
    case facebookURL = "https://www.facebook.com/FreespokeSearch"
    case freespokeBlogURL = "https://freespoke.substack.com/"
    case ourNewslettersURL = "https://about.freespoke.com/SignUp"
    case freespokePremiumURL = "https://subscriptions.freespoke.com/signup"
    case getInTouchURL = "https://freespoke-support.freshdesk.com/support/tickets/new"
    case newsURL = "https://freespoke.com/news"
    case shopURL = "https://freespoke.com/products"
    case aboutFreespokeURL = "https://freespoke.com/about"
    case githubiOSURL = "https://github.com/Freespoke/freespoke-browser-ios"
    case electionURL = "https://freespoke.com/election/2024"
    case appleNativeSubscriptions = "itms-apps://apps.apple.com/account/subscriptions" // "https://apps.apple.com/account/subscriptions"
    
    // MARK: - One Signal
    
    enum OneSignalConstants {
        static var oneSignalId: String {
            switch FreespokeEnvironment.current {
            case .production:
                // TODO: should be replaced to production app id. For now will be used staging app id
                return "de8ebc15-f8ef-427a-b1c1-f312ce831eea"
            case .staging:
                // one signall app id (stagincId = "de8ebc15-f8ef-427a-b1c1-f312ce831eea")
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
    static let charcoalGrayColor = Utils.hexStringToUIColor(hex: "#292929")
    static let gunmetalGrayColor = Utils.hexStringToUIColor(hex: "#525252")
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
