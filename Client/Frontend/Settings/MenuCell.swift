// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Storage
import Shared

protocol MenuCellDelegate: class {
    func didSelectOption(curCellType: MenuCellType)
}

class MenuCell: UITableViewCell {
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var imgViewOption: UIImageView!
    @IBOutlet weak var imgViewRightArrow: UIImageView!
    @IBOutlet weak var btnBackground: UIButton!
    
    weak var delegate: MenuCellDelegate?
    
    var curCellType : MenuCellType!
    var curCellImageType : MenuCellImageType!
    var theme: Theme?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnBackground(_ sender: Any) {
        delegate?.didSelectOption(curCellType: curCellType)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Custom Methods
    
    private func setupBackgroundLayerWith(color: UIColor) {
        viewBackground.layer.cornerRadius       = 4
        viewBackground.layer.borderWidth        = 1
        viewBackground.layer.borderColor        = color.cgColor
        viewBackground.layer.masksToBounds      = true
    }
    
    func setupCell(cellType: MenuCellType, cellImageType: MenuCellImageType) {
        curCellType = cellType
        curCellImageType = cellImageType
        
        btnBackground.setTitle(curCellType.rawValue, for: .normal)
        imgViewOption.image = UIImage(named: curCellImageType.rawValue)
        
        if let theme = theme {
            
            switch theme.type {
            case .dark:
                setupBackgroundLayerWith(color: .blackColor)
                imgViewOption.tintColor = .gray2
                imgViewRightArrow.tintColor = .white
                btnBackground.setTitleColor(.white, for: .normal)
                
            case .light:
                setupBackgroundLayerWith(color: .whiteColor)
                imgViewOption.tintColor = .inactiveToolbar
                imgViewRightArrow.tintColor = .blackColor
                btnBackground.setTitleColor(.blackColor, for: .normal)
            }
        }
    }
}
