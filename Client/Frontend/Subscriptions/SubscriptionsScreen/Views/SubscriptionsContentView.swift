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
                self.lineView.backgroundColor = UIColor.blackColor
            case .light:
                self.lineView.backgroundColor = UIColor.whiteColor
            }
        }
    }
    
    private func addingViews() {
        self.addSubview(self.topTitleView)
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
    
    func configure(currentTheme: Theme?, lblTitleText: String, lblSubtitleText: String?) {
        self.topTitleView.configure(currentTheme: currentTheme,
                                    lblTitleText: lblTitleText,
                                    lblSubtitleText: lblSubtitleText,
                                    logoIsHidden: false)
    }
}
