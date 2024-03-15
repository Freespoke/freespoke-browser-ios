// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class OnboardingContrentView: UIView {
    private lazy var topTitleView = OnboardingTopTitleView()
    
    private var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private var imageLight: UIImage?
    private var imageDark: UIImage?
    
    private var currentTheme: Theme?
    
    required init(currentTheme: Theme?) {
        self.currentTheme = currentTheme
        super.init(frame: .zero)
        self.addingViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            self.backgroundColor = .clear
            
            switch theme.type {
            case .dark:
                self.imageView.image = self.imageDark
            case .light:
                self.imageView.image = self.imageLight
            }
        }
    }
    
    private func addingViews() {
        self.addSubview(self.imageView)
        self.addSubview(self.topTitleView)
    }
    
    private func setupConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.topTitleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topTitleView.topAnchor.constraint(equalTo: self.topAnchor, constant: UIDevice.current.isPad ? 15 : 0),
            self.topTitleView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            self.topTitleView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            self.topTitleView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            
            self.imageView.topAnchor.constraint(equalTo: self.topTitleView.bottomAnchor, constant: 32),
            self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func configure(currentTheme: Theme?, lblTitleText: String, lblSubtitleText: String, imageLight: UIImage?, imageDark: UIImage?) {
        self.topTitleView.configure(currentTheme: currentTheme,
                                    lblTitleText: lblTitleText,
                                    lblSubtitleText: lblSubtitleText,
                                    logoIsHidden: true)
        self.imageLight = imageLight
        self.imageDark = imageDark
        
        self.applyTheme()
    }
}
