// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

protocol TrendingNewsCollectionViewCellDelegate {
    func didBtnPhoto(indexPath: IndexPath)
    func didBtnViewSummary(indexPath: IndexPath)
}

class TrendingNewsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgLeft: UIImageView!
    @IBOutlet weak var imgRight: UIImageView!
    @IBOutlet weak var imgPublisherFirst: UIImageView!
    @IBOutlet weak var imgPublisherSecond: UIImageView!
    @IBOutlet weak var viewPublisherFirst: UIView!
    @IBOutlet weak var viewPublisherSecond: UIView!
    @IBOutlet weak var viewPublisher: UIView!
    @IBOutlet weak var lblPublisher: UILabel!
    @IBOutlet weak var viewBackgroundImage: UIView!
    @IBOutlet weak var lblUpdated: UILabel!
    @IBOutlet weak var lblSources: UILabel!
    @IBOutlet weak var lblLeft: UILabel!
    @IBOutlet weak var lblMiddle: UILabel!
    @IBOutlet weak var lblRight: UILabel!
    
    @IBOutlet weak var viewBackgroundSources: UIView!
    
    @IBOutlet weak var btnPhoto: UIButton!
    
    var indexPath: IndexPath!
    
    var delegate: TrendingNewsCollectionViewCellDelegate?
    
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
        
        viewBackgroundImage.layer.cornerRadius     = 4
        viewBackgroundImage.layer.borderWidth      = 1
        viewBackgroundImage.layer.masksToBounds    = true
        
        imgPublisherFirst.layer.cornerRadius     = 12
        imgPublisherFirst.layer.masksToBounds    = true
        
        imgPublisherSecond.layer.cornerRadius     = 12
        imgPublisherSecond.layer.masksToBounds    = true
        
        viewPublisher.layer.cornerRadius     = 12
        viewPublisher.layer.masksToBounds    = false

        viewPublisherFirst.layer.cornerRadius     = 12
        viewPublisherFirst.layer.masksToBounds    = false
        
        viewPublisherSecond.layer.cornerRadius     = 12
        viewPublisherSecond.layer.masksToBounds    = false
        
        viewPublisherFirst.layer.applySketchShadow(color: .black,
                                              alpha: 1,
                                              x: 0,
                                              y: 0,
                                              blur: 4,
                                              spread: -12)

        viewPublisherSecond.layer.applySketchShadow(color: .black,
                                              alpha: 1,
                                              x: 0,
                                              y: 0,
                                              blur: 4,
                                              spread: -12)

        viewPublisher.layer.applySketchShadow(color: .black,
                                              alpha: 1,
                                              x: 0,
                                              y: 0,
                                              blur: 4,
                                              spread: -12)
    }
    
    private func setTheme(isDark: Bool) {
        if !isDark {
            lblTitle.textColor = .white
            viewBackgroundImage.layer.borderColor = UIColor.blackColor.cgColor
            
            viewBackgroundSources.backgroundColor = .white.withAlphaComponent(0.05)
            
            imgLeft.tintColor = .lightGray
            imgRight.tintColor = .lightGray
            
            lblUpdated.textColor = .lightGray
            btnPhoto.setTitleColor(.lightGray, for: .normal)
            
            lblSources.textColor = .white
            lblLeft.textColor = .lightGray
            lblMiddle.textColor = .lightGray
            lblRight.textColor = .lightGray
        }
        else {
            lblTitle.textColor = .blackColor
            viewBackgroundImage.layer.borderColor = UIColor.whiteColor.cgColor
            
            viewBackgroundSources.backgroundColor = .gray7
            
            imgLeft.tintColor = .gray2
            imgRight.tintColor = .gray2
            
            lblUpdated.textColor = .gray2
            btnPhoto.setTitleColor(.gray2, for: .normal)
            
            lblSources.textColor = .blackColor
            lblLeft.textColor = .gray2
            lblMiddle.textColor = .gray2
            lblRight.textColor = .gray2
        }
    }
    
    //: MARK: - Action Methods
    
    @IBAction func btnPhoto(_ sender: Any) {
        delegate?.didBtnPhoto(indexPath: indexPath)
    }
    
    @IBAction func btnViewSummary(_ sender: Any) {
        delegate?.didBtnViewSummary(indexPath: indexPath)
    }
}

extension CALayer {
  func applySketchShadow(
    color: UIColor = .black,
    alpha: Float = 0.5,
    x: CGFloat = 0,
    y: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0)
  {
    masksToBounds = false
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}
