// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import Shared

class SubscriptionsContentView: UIView {
    private var iconImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "onboarding_logo_torch")
        imgView.contentMode = .scaleToFill
        return imgView
    }()
    
    private var labelsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 8
        return sv
    }()
    
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
    
    private var lineView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var privilegesStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.spacing = 0
        return sv
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
                self.lineView.backgroundColor = UIColor.blackColor
            case .light:
                self.lblTitle.textColor = UIColor.blackColor
                self.lblSubtitle.textColor = UIColor.blackColor
                self.lineView.backgroundColor = UIColor.whiteColor
            }
        }
    }
    
    private func addingViews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.labelsStackView)
        self.addSubview(self.lineView)
        self.addSubview(self.privilegesStackView)
        self.addPrivilegesItems()
    }
    
    private func addPrivilegesItems() {
        let item1 = SubscriptionPrivilegesItem(currentTheme: self.currentTheme,
                                               image: UIImage(named: "img_onboarding_ad_free_search_icon"),
                                               titleText: "Ad Free Search",
                                               subtitleText: "Block unwanted ads in search results",
                                               bottomLineVisible: true)
        let item2 = SubscriptionPrivilegesItem(currentTheme: self.currentTheme,
                                               image: UIImage(named: "img_onboarding_without_bias_icon"),
                                               titleText: "Without Bias",
                                               subtitleText: "Get the unfiltered truth",
                                               bottomLineVisible: true)
        let item3 = SubscriptionPrivilegesItem(currentTheme: self.currentTheme,
                                               image: UIImage(named: "img_onboarding_porn_free_icon"),
                                               titleText: "Porn Free",
                                               subtitleText: "Fight sextrafficking",
                                               bottomLineVisible: false)
        self.privilegesStackView.addArrangedSubview(item1)
        self.addLineViewToItem(item: item1)
        self.privilegesStackView.addArrangedSubview(item2)
        self.addLineViewToItem(item: item2)
        self.privilegesStackView.addArrangedSubview(item3)
    }
    
    private func addLineViewToItem(item: SubscriptionPrivilegesItem) {
        let line = UIView()
        line.backgroundColor = self.currentTheme?.type == .dark ? UIColor.blackColor : UIColor.whiteColor
        
        self.addSubviews(line)
        
        line.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            line.bottomAnchor.constraint(equalTo: item.bottomAnchor, constant: 0),
            line.heightAnchor.constraint(equalToConstant: 1),
            line.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            line.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.privilegesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.iconImageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 50),
            self.iconImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 32),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 32),
            
            self.labelsStackView.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor, constant: 8),
            self.labelsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            self.labelsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            
            self.lineView.topAnchor.constraint(equalTo: self.labelsStackView.bottomAnchor, constant: UIDevice.current.isPad ? 32 : 16),
            self.lineView.heightAnchor.constraint(equalToConstant: 1),
            self.lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        if UIDevice.current.isPad {
            NSLayoutConstraint.activate([
                self.privilegesStackView.topAnchor.constraint(equalTo: self.lineView.bottomAnchor, constant: 8),
                self.privilegesStackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 40),
                self.privilegesStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -40),
                self.privilegesStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                self.privilegesStackView.widthAnchor.constraint(equalToConstant: 400),
                self.privilegesStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.privilegesStackView.topAnchor.constraint(equalTo: self.lineView.bottomAnchor, constant: 8),
                self.privilegesStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
                self.privilegesStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
                self.privilegesStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
            ])
        }
    }
    
    func configure(currentTheme: Theme?, lblTitleText: String, lblSubtitleText: String?) {
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
