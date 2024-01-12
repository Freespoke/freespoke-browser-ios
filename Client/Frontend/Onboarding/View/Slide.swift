// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class Slide: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblFirstTitle: UILabel!
    @IBOutlet weak var lblFirstDesc: UILabel!
    
    @IBOutlet weak var viewSecondSlide: UIView!
    @IBOutlet weak var viewSegments: UIView!
    
    // MARK: - View Methods
    
    /*
     override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
     super.traitCollectionDidChange(previousTraitCollection)
     
     switch LegacyThemeManager.instance.currentName {
     case .normal:
     setTheme(isDark: true)
     
     case .dark:
     setTheme(isDark: false)
     }
     }
     */
    
    // MARK: - Custom Methods
    
    private func setTheme(isDark: Bool) {
        if !isDark {
            lblTitle.textColor = .white
        }
        else {
            lblTitle.textColor = .blackColor
        }
    }
}
