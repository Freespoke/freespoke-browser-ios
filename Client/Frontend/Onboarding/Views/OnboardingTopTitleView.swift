// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class OnboardingTopTitleView: UIView {
    private var iconImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "onboarding_logo_torch")
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    
    private var logoStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        return sv
    }()
    
    private var labelsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = UIDevice.current.isPad ? 32 : 8
        return sv
    }()
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = UIColor.onboardingTitleDark
        lbl.font = UIDevice.current.isPad ? UIFont.sourceSerifProFontFont(.semiBold, size: 52) : UIFont.sourceSerifProFontFont(.semiBold, size: 28)
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
    
    private var spaceBetweenImageAndLabelsConstraint: NSLayoutConstraint?
    
    private var currentTheme: Theme?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
                self.lblTitle.textColor = UIColor.whiteColor
                self.lblSubtitle.textColor = UIColor.whiteColor
            case .light:
                self.lblTitle.textColor = UIColor.blackColor
                self.lblSubtitle.textColor = UIColor.blackColor
            }
        }
    }
    
    private func addingViews() {
        self.addSubview(self.logoStackView)
        self.addSubview(self.labelsStackView)
    }
    
    private func setupConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.logoStackView.translatesAutoresizingMaskIntoConstraints = false
        self.labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageViewHeight: CGFloat = UIDevice.current.isPad ? 52 : 32
        
        self.spaceBetweenImageAndLabelsConstraint = self.labelsStackView.topAnchor.constraint(equalTo: self.logoStackView.bottomAnchor, constant: 8)
        self.spaceBetweenImageAndLabelsConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            self.iconImageView.heightAnchor.constraint(equalToConstant: iconImageViewHeight),
            self.iconImageView.widthAnchor.constraint(equalTo: self.iconImageView.heightAnchor),
            
            self.logoStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: UIDevice.current.isPad ? 15 : 0),
            self.logoStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            
            self.labelsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            self.labelsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            self.labelsStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func configure(currentTheme: Theme?, lblTitleText: String, lblSubtitleText: String?, logoIsHidden: Bool) {
        self.currentTheme = currentTheme
        self.applyTheme()
        
        self.logoStackView.arrangedSubviews.forEach({ [weak self] in
            guard let self = self else { return }
            self.logoStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        
        self.iconImageView.isHidden = logoIsHidden
        
        if !logoIsHidden {
            self.logoStackView.addArrangedSubview(self.iconImageView)
            self.spaceBetweenImageAndLabelsConstraint?.constant = 8
        } else {
            self.spaceBetweenImageAndLabelsConstraint?.constant = 0
        }
        
        self.labelsStackView.arrangedSubviews.forEach({ [weak self] in
            guard let self = self else { return }
            self.labelsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        
        self.lblTitle.text = lblTitleText
        self.labelsStackView.addArrangedSubview(self.lblTitle)
        
        if let subtitleText = lblSubtitleText {
            self.lblSubtitle.text = subtitleText
            self.labelsStackView.addArrangedSubview(self.lblSubtitle)
        }
    }
}
