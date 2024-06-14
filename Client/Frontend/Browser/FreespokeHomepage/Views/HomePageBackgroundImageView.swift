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
        img.layer.masksToBounds = true
        return img
    }()
    
    private var imgViewHeightConstraint: NSLayoutConstraint?
    
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.updateConstraints()
    }
    
    func applyTheme(currentTheme: Theme) {
        switch currentTheme.type {
        case .light:
            self.imgView.image = UIImage(named: "img_home_iceberg_background_image_light")
        case .dark:
            self.imgView.image = UIImage(named: "img_home_iceberg_background_image_dark")
        }
    }
    
    func orientationDidChange() {
        self.updateConstraints()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if UIDevice.current.isPad {
            if ScreenUtilities.isLandscape {
                self.imgViewHeightConstraint?.constant = 500
            } else {
                self.imgViewHeightConstraint?.constant = 360
            }
        } else {
            if ScreenUtilities.isLandscape {
                self.imgViewHeightConstraint?.constant = 300
            } else {
                self.imgViewHeightConstraint?.constant = 350
            }
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
        
        self.imgViewHeightConstraint = self.imgView.heightAnchor.constraint(equalToConstant: 350)
        self.imgViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            self.imgView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            self.imgView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            self.imgView.topAnchor.constraint(equalTo: self.topAnchor),
            self.imgView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
