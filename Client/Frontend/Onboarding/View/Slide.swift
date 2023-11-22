// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

protocol SlideDelegate: class {
    func didSelectBreakingNews(value: Bool)
    func didSelectShopUSADiscounts(value: Bool)
    func didSelectGeneralAlerts(value: Bool)
}

class Slide: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblFirstTitle: UILabel!
    @IBOutlet weak var lblFirstDesc: UILabel!

    @IBOutlet weak var viewSecondSlide: UIView!
    @IBOutlet weak var viewSegments: UIView!
    
    @IBOutlet weak var viewBreakingNews: UIView!
    @IBOutlet weak var viewShopUSA: UIView!
    @IBOutlet weak var viewGeneralAlerts: UIView!
    
    @IBOutlet weak var lblTitleBreakingNews: UILabel!
    @IBOutlet weak var lblTitleShopUSA: UILabel!
    @IBOutlet weak var lblTitleGeneralAlerts: UILabel!
    
    @IBOutlet weak var lblDescBreakingNews: UILabel!
    @IBOutlet weak var lblDescUSA: UILabel!
    @IBOutlet weak var lblDescGeneralAlerts: UILabel!
    
    @IBOutlet weak var switchBreakingNews: UISwitch!
    @IBOutlet weak var switchShopUSA: UISwitch!
    @IBOutlet weak var switchGeneralAlerts: UISwitch!
    
    weak var delegate: SlideDelegate?
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    // MARK: - Custom Methods
    
    private func setupUI() {
        viewBreakingNews.layer.cornerRadius     = 12
        viewBreakingNews.layer.borderWidth      = 1
        viewBreakingNews.layer.masksToBounds    = true
        
        viewShopUSA.layer.cornerRadius     = 12
        viewShopUSA.layer.borderWidth      = 1
        viewShopUSA.layer.masksToBounds    = true
        
        viewGeneralAlerts.layer.cornerRadius     = 12
        viewGeneralAlerts.layer.borderWidth      = 1
        viewGeneralAlerts.layer.masksToBounds    = true
    }
    
    private func setTheme(isDark: Bool) {
        if !isDark {
            lblTitle.textColor = .white
        }
        else {
            lblTitle.textColor = .blackColor
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func switchBreakingNews(_ sender: UISwitch) {
        delegate?.didSelectBreakingNews(value: sender.isOn)
    }
    
    @IBAction func switchShopUSA(_ sender: UISwitch) {
        delegate?.didSelectShopUSADiscounts(value: sender.isOn)
    }
    
    @IBAction func switchGeneralAlerts(_ sender: UISwitch) {
        delegate?.didSelectGeneralAlerts(value: sender.isOn)
    }
}
