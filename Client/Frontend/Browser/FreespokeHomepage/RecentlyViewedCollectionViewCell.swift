// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class RecentlyViewedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var viewBackgroundImage: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch LegacyThemeManager.instance.currentName {
        case .normal:
            setTheme(isDark: true)
            
        case .dark:
            setTheme(isDark: false)
        }
    }
    
    //: MARK: - Custom Methods
    
    private func setupUI() {
        switch LegacyThemeManager.instance.currentName {
        case .normal:
            setTheme(isDark: true)
            
        case .dark:
            setTheme(isDark: false)
        }
        
        viewBackgroundImage.layer.cornerRadius     = 8
        viewBackgroundImage.layer.borderWidth      = 1
        viewBackgroundImage.layer.masksToBounds    = true
    }
    
    private func setTheme(isDark: Bool) {
        if !isDark {
            viewBackgroundImage.backgroundColor = .clear
            lblTitle.textColor = .white
            viewBackgroundImage.layer.borderColor = UIColor.blackColor.cgColor
        }
        else {
            viewBackgroundImage.backgroundColor = .gray7
            lblTitle.textColor = .blackColor
            viewBackgroundImage.layer.borderColor = UIColor.whiteColor.cgColor
        }
    }
}
