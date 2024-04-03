// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import Shared

class SubscriptionsContentView: UIView {
    private lazy var topTitleView = OnboardingTopTitleView()
    
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
    
    private let item1 = SubscriptionPrivilegesItem(image: UIImage(named: "img_onboarding_ad_free_search_icon"),
                                                   titleText: "Ad-Free",
                                                   subtitleText: "Block unwanted ads while browsing",
                                                   bottomLineVisible: true)
    
    private let item2 = SubscriptionPrivilegesItem(image: UIImage(named: "img_onboarding_without_bias_icon"),
                                                   titleText: "Without Bias",
                                                   subtitleText: "Get the unfiltered truth.",
                                                   bottomLineVisible: true)
    
    private let item3 = SubscriptionPrivilegesItem(image: UIImage(named: "img_onboarding_porn_free_icon"),
                                                   titleText: "Porn-Free",
                                                   subtitleText: "Fight human trafficking.",
                                                   bottomLineVisible: false)
    
    private let lineSeparator1 = UIView()
    private let lineSeparator2 = UIView()
    
    required init() {
        super.init(frame: .zero)
        self.addingViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyTheme(currentTheme: Theme) {
        self.topTitleView.applyTheme(currentTheme: currentTheme)
        self.item1.applyTheme(currentTheme: currentTheme)
        self.item2.applyTheme(currentTheme: currentTheme)
        self.item3.applyTheme(currentTheme: currentTheme)
        
        self.backgroundColor = .clear
        self.lineSeparator1.backgroundColor = currentTheme.type == .dark ? UIColor.blackColor : UIColor.whiteColor
        self.lineSeparator2.backgroundColor = currentTheme.type == .dark ? UIColor.blackColor : UIColor.whiteColor
        
        switch currentTheme.type {
        case .dark:
            self.lineView.backgroundColor = UIColor.blackColor
        case .light:
            self.lineView.backgroundColor = UIColor.whiteColor
        }
    }
    
    private func addingViews() {
        self.addSubview(self.topTitleView)
        self.addSubview(self.lineView)
        self.addSubview(self.privilegesStackView)
        self.addPrivilegesItems()
    }
    
    private func addPrivilegesItems() {
        self.privilegesStackView.addArrangedSubview(item1)
        self.addLineViewToItem(item: item1, lineSeparator: self.lineSeparator1)
        self.privilegesStackView.addArrangedSubview(item2)
        self.addLineViewToItem(item: item2, lineSeparator: self.lineSeparator2)
        self.privilegesStackView.addArrangedSubview(item3)
    }
    
    private func addLineViewToItem(item: SubscriptionPrivilegesItem, lineSeparator: UIView) {
        
        self.addSubviews(lineSeparator)
        
        lineSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lineSeparator.bottomAnchor.constraint(equalTo: item.bottomAnchor, constant: 0),
            lineSeparator.heightAnchor.constraint(equalToConstant: 1),
            lineSeparator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            lineSeparator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupConstraints() {
        self.topTitleView.translatesAutoresizingMaskIntoConstraints = false
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.privilegesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topTitleView.topAnchor.constraint(equalTo: self.topAnchor, constant: UIDevice.current.isPad ? 120 : 105),
            self.topTitleView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            self.topTitleView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            self.topTitleView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            
            self.lineView.topAnchor.constraint(equalTo: self.topTitleView.bottomAnchor, constant: UIDevice.current.isPad ? 32 : 16),
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
    
    func configure(lblTitleText: String, lblSubtitleText: String?) {
        self.topTitleView.configure(lblTitleText: lblTitleText,
                                    lblSubtitleText: lblSubtitleText,
                                    logoIsHidden: false)
    }
}
