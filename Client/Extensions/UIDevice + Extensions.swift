// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Foundation

extension UIDevice {
    
    // MARK: Properties
    
    var isPhone: Bool {
        self.userInterfaceIdiom == .phone
    }
    
    var isPad: Bool {
        self.userInterfaceIdiom == .pad
    }
    
    var isTV: Bool {
        self.userInterfaceIdiom == .tv
    }
    
    var isCarPlay: Bool {
        self.userInterfaceIdiom == .carPlay
    }
    
    var isMac: Bool {
        ProcessInfo.processInfo.isiOSAppOnMac
    }
}

// MARK: - Orientation

extension UIDevice {
    func setOrientation(_ orientation: UIInterfaceOrientation) {
        self.setValue(orientation.rawValue, forKeyPath: "orientation")
    }
}
