// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import Shared

class OnboardingWelcomeScreenContentView: UIView {
    private var iconImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "onboarding_logo_torch")
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = UIColor.onboardingTitleDark
        lbl.font = UIDevice.current.isPad ? UIFont.sourceSerifProFontFont(.semiBold, size: 52) : UIFont.sourceSerifProFontFont(.semiBold, size: 36)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private var lblSubtitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = UIColor.blackColor
        lbl.font = UIDevice.current.isPad ? UIFont.sourceSansProFont(.regular, size: 20) : UIFont.sourceSansProFont(.regular, size: 16)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private var lblSecondSubtitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = UIColor.blackColor
        lbl.font = UIDevice.current.isPad ? UIFont.sourceSansProFont(.semiBold, size: 20) :  UIFont.sourceSansProFont(.bold, size: 16)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private var currentTheme: Theme?
    
    required init(currentTheme: Theme?) {
        self.currentTheme = currentTheme
        super.init(frame: .zero)
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareUI() {
        self.applyTheme()
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            self.backgroundColor = .clear
            
            switch theme.type {
            case .dark:
                self.lblTitle.textColor = UIColor.whiteColor
                self.lblSubtitle.textColor = UIColor.whiteColor
                self.lblSecondSubtitle.textColor = UIColor.whiteColor
            case .light:
                self.lblTitle.textColor = UIColor.blackColor
                self.lblSubtitle.textColor = UIColor.blackColor
                self.lblSecondSubtitle.textColor = UIColor.blackColor
            }
        }
    }
    
    private func addingViews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.lblTitle)
        self.addSubview(self.lblSubtitle)
        self.addSubview(self.lblSecondSubtitle)
    }
    
    private func setupConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.lblSubtitle.translatesAutoresizingMaskIntoConstraints = false
        self.lblSecondSubtitle.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageViewHeight: CGFloat = UIDevice.current.isPad ? 52 : 32
        
        NSLayoutConstraint.activate([
            self.iconImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.iconImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            self.iconImageView.heightAnchor.constraint(equalToConstant: iconImageViewHeight),
            self.iconImageView.widthAnchor.constraint(equalTo: self.iconImageView.heightAnchor),
            
            self.lblTitle.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor, constant: 32),
            self.lblTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            self.lblTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            
            self.lblSubtitle.topAnchor.constraint(equalTo: self.lblTitle.bottomAnchor, constant: 32),
            self.lblSubtitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            self.lblSubtitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            
            self.lblSecondSubtitle.topAnchor.constraint(equalTo: self.lblSubtitle.bottomAnchor, constant: 5),
            self.lblSecondSubtitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            self.lblSecondSubtitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            self.lblSecondSubtitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
    
    func configure(currentTheme: Theme?, lblTitleText: String, lblSubtitleText: String, lblSecondSubtitleText: String) {
        self.lblTitle.text = lblTitleText
        self.lblSubtitle.text = lblSubtitleText
        self.lblSecondSubtitle.text = lblSecondSubtitleText
    }
}
