// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

final class TrendingItemCell: UICollectionViewCell, ReusableCell {
    
    private let imgIcon: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "imgGrayLogo")
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    private let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = DynamicFontHelper.defaultHelper.preferredFont(withTextStyle: .title1, size: 17)
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()
    
    private let viewSeparator: UIView = {
        let view = UIView()
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareUI() {
        self.contentView.backgroundColor = .clear//green
    }
    
    private func addingViews() {
        self.contentView.addSubview(self.imgIcon)
        self.contentView.addSubview(self.lblTitle)
        self.contentView.addSubview(self.viewSeparator)
    }
    
    private func setupConstraints() {
        self.imgIcon.translatesAutoresizingMaskIntoConstraints = false
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.viewSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.imgIcon.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor, constant: 0),
            self.imgIcon.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.imgIcon.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.imgIcon.bottomAnchor.constraint(lessThanOrEqualTo: self.viewSeparator.topAnchor, constant: 0),
            self.imgIcon.widthAnchor.constraint(equalToConstant: 13),
            self.imgIcon.heightAnchor.constraint(equalToConstant: 18),
            
            self.lblTitle.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 9),
            self.lblTitle.leadingAnchor.constraint(equalTo: self.imgIcon.trailingAnchor, constant: 12),
            self.lblTitle.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -12),
            self.lblTitle.bottomAnchor.constraint(equalTo: self.viewSeparator.topAnchor, constant: -9),
            
            self.viewSeparator.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.viewSeparator.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            self.viewSeparator.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            self.viewSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func setData(title: String?) {
        self.lblTitle.text = title
    }
    
    func applyTheme(theme: Theme) {
        self.lblTitle.textColor = theme.colors.neutralsGrey
        self.viewSeparator.backgroundColor = theme.colors.neutralViewGrey
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        contentView.layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: UIView.layoutFittingCompressedSize.height))
        return size
    }
}
