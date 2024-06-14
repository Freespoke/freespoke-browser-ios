// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

enum ScreenUtilities {
    
    enum Orientation {
        case portrait
        case portraitUpsideDown
        case landscapeLeft
        case landscapeRight
        
        var interfaceOrientation: UIInterfaceOrientation {
            switch self {
            case .portrait:
                return .portrait
            case .portraitUpsideDown:
                return .portraitUpsideDown
            case .landscapeLeft:
                return .landscapeLeft
            case .landscapeRight:
                return .landscapeRight
            }
        }
        
        var interfaceOrientationMask: UIInterfaceOrientationMask {
            switch self {
            case .portrait:
                return .portrait
            case .portraitUpsideDown:
                return .portraitUpsideDown
            case .landscapeLeft:
                return .landscapeLeft
            case .landscapeRight:
                return .landscapeRight
            }
        }
    }
    
    static var width: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var height: CGFloat {
        UIScreen.main.bounds.height
    }
    
    static var isLandscape: Bool {
        if #available(iOS 16.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isLandscape ?? false
        } else {
            return UIDevice.current.orientation.isLandscape
        }
    }
    
    static var isPortrait: Bool {
        !self.isLandscape
    }
    
    static func updateScreenOrientation(_ orientation: Orientation, in viewController: UIViewController) {
        
        DispatchQueue.main.async { [weak viewController] in
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                viewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                viewController?.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                windowScene?.requestGeometryUpdate(
                    .iOS(interfaceOrientations: orientation.interfaceOrientationMask)
                )
            } else {
                UIDevice.current.setOrientation(orientation.interfaceOrientation)
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
}
