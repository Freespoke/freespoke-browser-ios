// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

enum NotificationKeyNameForValue: String {
    case host
}

extension Notification.Name {
    // MARK: Authentication
    static let freespokeUserAuthChanged = Notification.Name("freespoke_user_auth_changed")
    static let adBlockSettingsChanged = Notification.Name("adBlockSettingsChanged")
//    static let domainWasRemoved = Notification.Name("domainWasRemoved")
    static let disableAdBlockerForCurrentDomain = Notification.Name("disableAdBlockerForCurrentDomain")
    static let enableAdBlockerForCurrentDomain = Notification.Name("enableAdBlockerForCurrentDomain")
}
