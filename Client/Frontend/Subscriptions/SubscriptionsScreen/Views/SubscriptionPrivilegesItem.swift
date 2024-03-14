// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class SubscriptionPrivilegesItem: UIView {
    private var iconImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private var labelsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 2
        return sv
    }()
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.textColor = UIColor.blackColor
        lbl.font = UIFont.sourceSansProFont(.semiBold, size: 22)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    
    private var lblSubtitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.textColor = UIColor.gray2
        lbl.font = UIFont.sourceSansProFont(.regular, size: 14)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    
    private var lineView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var image: UIImage?
    private var titleText: String
    private var subtitleText: String
    private var bottomLineVisible: Bool
    
    private var currentTheme: Theme?
    
    required init(currentTheme: Theme?, image: UIImage?, titleText: String, subtitleText: String, bottomLineVisible: Bool) {
        self.currentTheme = currentTheme
        self.image = image
        self.titleText = titleText
        self.subtitleText = subtitleText
        self.bottomLineVisible = bottomLineVisible
        super.init(frame: .zero)
        
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareUI() {
        self.configure()
        self.applyTheme()
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            self.backgroundColor = .clear
            
            switch theme.type {
            case .dark:
                self.lblTitle.textColor = UIColor.whiteColor
                self.lblSubtitle.textColor = UIColor.lightGray
                self.lineView.backgroundColor = UIColor.blackColor
            case .light:
                self.lblTitle.textColor = UIColor.blackColor
                self.lblSubtitle.textColor = UIColor.gray2
                self.lineView.backgroundColor = UIColor.whiteColor
            }
        }
    }
    
    private func addingViews() {
        self.addSubview(self.iconImageView)
        self.labelsStackView.addArrangedSubview(self.lblTitle)
        self.labelsStackView.addArrangedSubview(self.lblSubtitle)
        self.addSubview(self.labelsStackView)
        self.addSubview(self.lineView)
    }
    
    private func setupConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.iconImageView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 10),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            self.iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -10),
            self.iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 32),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 32),
            
            self.labelsStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.labelsStackView.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 20),
            self.labelsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            
            self.lineView.topAnchor.constraint(equalTo: self.labelsStackView.bottomAnchor, constant: 16),
            self.lineView.heightAnchor.constraint(equalToConstant: 1),
            self.lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func configure() {
        self.iconImageView.image = self.image
        self.lblTitle.text = self.titleText
        self.lblSubtitle.text = self.subtitleText
        self.lineView.isHidden = !self.bottomLineVisible
    }
}
