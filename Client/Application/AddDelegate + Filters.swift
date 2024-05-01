// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

extension AppDelegate {
    
    func prepareFilters() {
        let defaults = UserDefaults.standard
        
        defaults.set(false, forKey: SettingsKeys.stringLiteralAdBlock)
        for hostFile in HostFileNames.allValues {
            defaults.set(false, forKey: hostFile.rawValue)
        }
    }
}

struct SettingsKeys {
    static let firstRun = "firstRun"
    static let trackHistory = "trackHistory"
    static let adBlockEnabled = "adBlockEnabled"
    static let stringLiteralAdBlock = "stringLiteralAdBlock"
    static let adBlockPurchased = "purchasedAdBlock"
    static let needToShowAdBlockAlert = "needToShowAdBlockAlert"
    static let searchEngineUrl = "searchEngineUrl"
    static let isEnabledBlocker = "isEnabledBlocker"
    static let domains = "domains"
}

enum HostFileNames: String {
    case adaway
    case camelon
    case zeus
    case tracker
    case adServerHosts
    case ultimateAdBlock
    case easyList
    case easyFanboyAnnoyance
    case easyPrivacyList
    
    static let allValues: [HostFileNames] = [.adaway, .camelon, .zeus, .tracker, .adServerHosts, .ultimateAdBlock, .easyList, .easyFanboyAnnoyance, .easyPrivacyList]
}
