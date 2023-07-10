// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit

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
    case freespokeURL = "https://freespoke.com/"
    case twitterURL = "https://twitter.com/FreespokeSearch/"
    case linkedinURL = "https://www.linkedin.com/company/freespoke-search/"
    case instagramURL = "https://www.instagram.com/freespokesearch/"
    case facebookURL = "https://www.facebook.com/FreespokeSearch"
    case freespokeBlogURL = "https://freespoke.substack.com/"
    case ourNewslettersURL = "https://about.freespoke.com/SignUp"
    case getInTouchURL = "https://freespoke-support.freshdesk.com/support/tickets/new"
    case newsURL = "https://freespoke.com/news"
    case shopURL = "https://freespoke.com/products"
    case githubiOSURL = "https://github.com/Freespoke/freespoke-browser-ios"
}

extension UIColor {
    static let redHomeToolbar = Utils.hexStringToUIColor(hex: "C43351")
}

class Utils {
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
