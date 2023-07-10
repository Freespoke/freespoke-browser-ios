// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit

protocol FreespokeHomepageViewDelegate {
    func didPressSearch()
    func didPressNews()
    func didPressShop()
}

class FreespokeHomepageView: UIView {
    let kCONTENT_XIB_NAME = "FreespokeHomepageView"
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var imgViewSearch: UIImageView!
    @IBOutlet weak var imgViewTop: UIImageView!
    @IBOutlet weak var imgViewBottom: UIImageView!
    @IBOutlet weak var imgViewNews: UIImageView!
    @IBOutlet weak var imgViewShop: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNews: UILabel!
    @IBOutlet weak var lblShop: UILabel!
    @IBOutlet weak var btnSerch: UIButton!
    @IBOutlet weak var btnNews: UIButton!
    @IBOutlet weak var btnShop: UIButton!
    
    @IBOutlet weak var viewNews: UIView!
    @IBOutlet weak var viewShop: UIView!
    @IBOutlet weak var viewSeparatorNews: UIView!
    @IBOutlet weak var viewSeparatorShop: UIView!
    
    var delegate: FreespokeHomepageViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // Custom Methods
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    func setUI() {
        btnSerch.layer.cornerRadius     = 12
        btnSerch.layer.borderWidth      = 1
        btnSerch.layer.masksToBounds    = true
        
        viewNews.layer.cornerRadius     = 4
        viewNews.layer.borderWidth      = 1
        viewNews.layer.masksToBounds    = true
        
        viewShop.layer.cornerRadius     = 4
        viewShop.layer.borderWidth      = 1
        viewShop.layer.masksToBounds    = true
    }
    
    // Actions Methods
    
    @IBAction func btnSearch(_ sender: Any) {
        delegate?.didPressSearch()
    }
    
    @IBAction func ntmNews(_ sender: Any) {
        delegate?.didPressNews()
    }
    
    @IBAction func btnShop(_ sender: Any) {
        delegate?.didPressShop()
    }
}

extension UIView {
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}

