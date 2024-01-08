// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class ShopUsaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTop: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
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
        
        imgView.layer.cornerRadius     = imgView.bounds.size.height / 2
        imgView.layer.masksToBounds    = true
        
        viewBackground.layer.cornerRadius     = 4
        viewBackground.layer.borderWidth      = 1
        viewBackground.layer.masksToBounds    = true
        
        lblTop.layer.cornerRadius     = 4
        lblTop.layer.masksToBounds    = true
    }
    
    private func setTheme(isDark: Bool) {
        if !isDark {
            lblTitle.textColor = .white
            viewBackground.layer.borderColor = UIColor.blackColor.cgColor
            

            lblTop.backgroundColor = Utils.hexStringToUIColor(hex: "4885FC").withAlphaComponent(0.12)
            
        }
        else {
            lblTitle.textColor = .blackColor
            viewBackground.layer.borderColor = UIColor.whiteColor.cgColor
            
            lblTop.backgroundColor = Utils.hexStringToUIColor(hex: "#EDF0F5")
        }
    }
}
