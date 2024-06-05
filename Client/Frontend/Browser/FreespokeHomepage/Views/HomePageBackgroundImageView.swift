// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class HomePageBackgroundImageView: UIView {
    
    // MARK: - Properties
    
    private lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        
        img.image = UIImage(named: "img_home_iceberg_background_image_light")
//        img.image = UIImage(named: "iceberg-hompage-background-cropped")
        img.layer.masksToBounds = true
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
        self.setupUI()
        self.addSubviews()
        self.addSubviewsConstraints()
    }
    
    private func setupUI() {
        
    }
    
    func applyTheme(currentTheme: Theme) {
        switch currentTheme.type {
        case .light:
            self.imgView.image = UIImage(named: "img_home_iceberg_background_image_light")
//            self.imgView.image = UIImage(named: "iceberg-hompage-background-cropped")
        case .dark:
            
            self.imgView.image = UIImage(named: "img_home_iceberg_background_image_dark")
//            self.imgView.image = UIImage(named: "iceberg-hompage-background-cropped")
        }
    }
}

// MARK: - Add Subviews

extension HomePageBackgroundImageView {
    
    private func addSubviews() {
        self.addSubview(self.imgView)
    }
    
    private func addSubviewsConstraints() {
        self.imgView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.imgView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            self.imgView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            self.imgView.topAnchor.constraint(equalTo: self.topAnchor),
            self.imgView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.imgView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }
}
