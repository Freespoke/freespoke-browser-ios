// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import AdSupport
import AppTrackingTransparency

extension ASIdentifierManager {
    // NOTE: if the user has enabled Limit Ad Tracking, this IDFA will be all zeros on a physical device
    static func identifierForAdvertising() -> (isAdvertisingTrackingEnabled: Bool, idfa: String?) {
        // Check whether advertising tracking is enabled
        if #available(iOS 14, *) {
            guard ATTrackingManager.trackingAuthorizationStatus == .authorized else {
                return (false, nil)
            }
        } else {
            guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
                return (false, nil)
            }
        }
            
        // Get and return IDFA
        return (true, ASIdentifierManager.shared().advertisingIdentifier.uuidString)
    }
    
    static var identifierForVendor: String? {
        // Check whether advertising tracking is enabled
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return nil
        }

        // Get and return IDFV
        return identifierForVendor.uuidString
    }
}
