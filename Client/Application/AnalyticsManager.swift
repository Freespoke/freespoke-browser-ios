// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import MatomoTracker

// MARK: Matomo events

enum AnalyticsManager {
    static func trackMatomoEvent(category: MatomoCategory, action: String, name: String, url: URL? = nil) {
        MatomoTracker.shared.track(eventWithCategory: category.rawValue,
                                   action: action,
                                   name: name,
                                   value: nil,
                                   url: url)
    }
}
