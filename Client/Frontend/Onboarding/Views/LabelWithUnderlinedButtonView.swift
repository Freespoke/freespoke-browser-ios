// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class LabelWithUnderlinedButtonView: UIView {
    private var contentView = UIView()
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = UIColor.blackColor
        lbl.font = UIFont.sourceSansProFont(.regular, size: 16)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    
    private let button: UnderlinedButton = {
        let btn = UnderlinedButton()
        btn.titleLabel?.font = UIFont.sourceSansProFont(.bold, size: 16)
        btn.setTitleColor(UIColor.blackColor, for: .normal)
        return btn
    }()
    
    private var currentTheme: Theme?
    
    var tapClosure: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
    }
    
    private func prepareUI() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.button.addTarget(self,
                              action: #selector(self.btnTapped(_:)),
                              for: .touchUpInside)
    }
    
    private func addingViews() {
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.lblTitle)
        self.contentView.addSubview(self.button)
    }
    
    private func setupConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.contentView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 0),
            self.contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.lblTitle.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            self.lblTitle.heightAnchor.constraint(greaterThanOrEqualToConstant: 22),
            self.lblTitle.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.lblTitle.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            self.button.centerYAnchor.constraint(equalTo: self.lblTitle.centerYAnchor, constant: 0),
            self.button.leadingAnchor.constraint(equalTo: self.lblTitle.trailingAnchor, constant: 5),
            self.button.heightAnchor.constraint(equalToConstant: 40),
            self.button.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        ])
    }
    
    func configure(currentTheme: Theme?, lblTitleText: String, btnTitleText: String) {
        self.currentTheme = currentTheme
        self.lblTitle.text = lblTitleText
        self.button.setTitle(btnTitleText, for: .normal)
        self.applyTheme()
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            switch theme.type {
            case .dark:
                self.lblTitle.textColor = UIColor.whiteColor
                self.button.setTitleColor(UIColor.whiteColor, for: .normal)
            case .light:
                self.lblTitle.textColor = UIColor.blackColor
                self.button.setTitleColor(UIColor.blackColor, for: .normal)
            }
        }
    }
    
    @objc private func btnTapped(_ sender: UIButton) {
        self.tapClosure?()
    }
}
