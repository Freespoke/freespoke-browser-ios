// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class OnboardingContrentView: UIView {
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = UIColor.onboardingTitleDark
        lbl.font = UIFont.sourceSerifProFontFont(.semiBold, size: 28)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private var lblSubtitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = UIColor.blackColor
        lbl.font = UIFont.sourceSansProFont(.regular, size: 16)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
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
            //            self.backgroundColor = theme.colors.layer1
            self.backgroundColor = .clear
            
            switch theme.type {
            case .dark:
                self.lblTitle.textColor = UIColor.whiteColor
                self.lblSubtitle.textColor = UIColor.lightGray
                self.imageView.image = self.imageDark
            case .light:
                self.lblTitle.textColor = UIColor.onboardingTitleDark
                self.lblSubtitle.textColor = UIColor.blackColor
                self.imageView.image = self.imageLight
            }
        }
    }
    
    private func addingViews() {
        self.addSubview(self.imageView)
        self.addSubview(self.lblTitle)
        self.addSubview(self.lblSubtitle)
    }
    
    private func setupConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.lblSubtitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.lblTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.lblTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            self.lblTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            
            self.lblSubtitle.topAnchor.constraint(equalTo: self.lblTitle.bottomAnchor, constant: 12),
            self.lblSubtitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            self.lblSubtitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            
            self.imageView.topAnchor.constraint(equalTo: self.lblSubtitle.bottomAnchor, constant: 32),
            self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func configure(currentTheme: Theme?, lblTitleText: String, lblSubtitleText: String, imageLight: UIImage?, imageDark: UIImage?) {
        self.lblTitle.text = lblTitleText
        self.lblSubtitle.text = lblSubtitleText
        self.imageLight = imageLight
        self.imageDark = imageDark
        
        self.applyTheme()
    }
}
