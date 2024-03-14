// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class PremiumUnlockedContentView: UIView {
    private lazy var topTitleView = OnboardingTopTitleView()
    
    private var premiumBadgeImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.image = UIImage(named: "img_unlocked_premium_badge")
        return imgView
    }()
    
    private var lblSecondSubtitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = UIColor.blackColor
        lbl.font = UIDevice.current.isPad ? UIFont.sourceSansProFont(.regular, size: 20) : UIFont.sourceSansProFont(.regular, size: 16)
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
                self.lblSecondSubtitle.textColor = UIColor.whiteColor
            case .light:
                self.lblSecondSubtitle.textColor = UIColor.blackColor
            }
        }
    }
    
    private func addingViews() {
        self.addSubview(self.topTitleView)
        self.addSubviews(self.premiumBadgeImageView)
        self.addSubview(self.lblSecondSubtitle)
    }
    
    private func setupConstraints() {
        self.topTitleView.translatesAutoresizingMaskIntoConstraints = false
        self.premiumBadgeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.lblSecondSubtitle.translatesAutoresizingMaskIntoConstraints = false
        
        let badgeImageViewTopOffset: CGFloat = UIScreen.main.bounds.height < 750 ? 30 : 70
        
        NSLayoutConstraint.activate([
            self.topTitleView.topAnchor.constraint(equalTo: self.topAnchor, constant: UIDevice.current.isPad ? 15 : 0),
            self.topTitleView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            self.topTitleView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            self.topTitleView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            
            self.premiumBadgeImageView.topAnchor.constraint(greaterThanOrEqualTo: self.topTitleView.bottomAnchor,
                                                            constant: badgeImageViewTopOffset),
            self.premiumBadgeImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            
            self.lblSecondSubtitle.topAnchor.constraint(equalTo: self.premiumBadgeImageView.bottomAnchor, constant: 16),
            self.lblSecondSubtitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            self.lblSecondSubtitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            self.lblSecondSubtitle.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: 0)
        ])
    }
    
    func configure(currentTheme: Theme?, lblTitleText: String, lblSubtitleText: String, lblSecondSubtitleText: String) {
        self.topTitleView.configure(currentTheme: currentTheme,
                                    lblTitleText: lblTitleText,
                                    lblSubtitleText: lblSubtitleText,
                                    logoIsHidden: false)
        
        self.lblSecondSubtitle.text = lblSecondSubtitleText
    }
}
