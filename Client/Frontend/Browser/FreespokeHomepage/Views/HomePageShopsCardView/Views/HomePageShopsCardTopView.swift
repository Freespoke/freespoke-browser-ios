// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class HomePageShopsCardTopView: UIView {
    // MARK: - Properties
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textColor = UIColor.neutralsGray01
        lbl.font = UIFont.sourceSansProFont(.bold, size: 18)
        lbl.text = "Shop USA Store".uppercased()
        return lbl
    }()
    
    private var lblSubTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textColor = UIColor.neutralsGray02
        lbl.font = UIFont.sourceSansProFont(.regular, size: 14)
        lbl.text = "Shop high quality products made in America."
        return lbl
    }()
    
    private let imageView: UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.layer.masksToBounds = true
        img.image = UIImage.templateImageNamed(ImageIdentifiers.imgShopsStore)
        img.tintColor = UIColor.neutralsGray01
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.addSubviews()
        self.addSubviewsConstraints()
        
        self.backgroundColor = UIColor.clear
    }
    
    func applyTheme(currentTheme: Theme) {
        switch currentTheme.type {
        case .light:
            self.backgroundColor = UIColor.clear
            self.lblTitle.textColor = UIColor.neutralsGray01
            self.lblSubTitle.textColor = UIColor.neutralsGray02
            self.imageView.tintColor = UIColor.neutralsGray01
        case .dark:
            self.backgroundColor = UIColor.clear
            self.lblTitle.textColor = UIColor.white
            self.lblSubTitle.textColor = UIColor.neutralsGray04
            self.imageView.tintColor = UIColor.white
        }
    }
}

// MARK: - Add Subviews

extension HomePageShopsCardTopView {
    private func addSubviews() {
        self.addSubview(self.lblTitle)
        self.addSubview(self.lblSubTitle)
        self.addSubview(self.imageView)
    }
    
    private func addSubviewsConstraints() {
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.lblSubTitle.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.lblTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.lblTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            
            self.imageView.centerYAnchor.constraint(equalTo: self.lblTitle.centerYAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: self.lblTitle.trailingAnchor, constant: 6),
            self.imageView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: 0),
            self.imageView.heightAnchor.constraint(equalToConstant: 16),
            self.imageView.heightAnchor.constraint(equalToConstant: 16),
            
            self.lblSubTitle.topAnchor.constraint(equalTo: self.lblTitle.bottomAnchor, constant: 6),
            self.lblSubTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            self.lblSubTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            self.lblSubTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
