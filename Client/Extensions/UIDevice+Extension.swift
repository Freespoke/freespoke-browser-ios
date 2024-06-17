// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

public enum Model: String {
    case simulator = "simulator"
    case iPhoneSE = "iPhone SE (1st gen)"
    case unrecognized = "?unrecognized?"
}

extension UIDevice {
    // returns true when device is an iPhone SE 1st gen
    var isTinyFormFactor: Bool {
        return UIDevice().type == .iPhoneSE
    }
    
    // Returns `true` if the device has a notch
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindowCustom?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }

    var isIphoneLandscape: Bool {
        return UIDevice().userInterfaceIdiom == .phone && UIWindow.isLandscape
    }

    private var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String(validatingUTF8: ptr)
            }
        }

        let modelMap: [String: Model] = [
            "i386": .simulator,
            "x86_64": .simulator,
            "iPhone8,4": .iPhoneSE,
        ]

        if let modelCode = modelCode, let model = modelMap[modelCode] {
            if model == .simulator,
               let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"],
               let simModel = modelMap[simModelCode] {
                return simModel
            }
            return model
        }
        return Model.unrecognized
    }
}
