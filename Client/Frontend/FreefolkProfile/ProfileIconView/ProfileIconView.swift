// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class ProfileIconView: UIView {
    private var decodedJWTToken: FreespokeJWTDecodeModel?
    
    let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    let initialsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor.onboardingTitleDark
        label.isHidden = true
        return label
    }()
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "img_avatar_icon_light")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 3
        return stackView
    }()
    
    private var stackViewLeadingConstraint: NSLayoutConstraint?
    private var stackViewTrailingConstraint: NSLayoutConstraint?
    
    var tapClosure: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        self.updateUI()
        self.addingViews()
        self.setupConstraints()
        self.addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
    func updateView(decodedJWTToken: FreespokeJWTDecodeModel?) {
        self.decodedJWTToken = decodedJWTToken
        self.updateUI()
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            Task {
                let userType = try await AppSessionManager.shared.userType()
                switch userType {
                case .authorizedWithoutPremium:
                    self.initialsLabel.text = AppSessionManager.shared.decodedJWTToken?.getInitialsLetters()
                    self.setAuthorizedWithoutPremiumUI()
                case .premiumOriginalApple, .premiumNotApple, .premiumBecauseAppleAccountHasSubscription:
                    self.initialsLabel.text = AppSessionManager.shared.decodedJWTToken?.getInitialsLetters()
                    self.setPremiumUI()
                case .unauthorizedWithoutPremium:
                    self.setUnauthorizedUI()
                case .unauthorizedWithPremium:
                    self.setUnauthorizedUIWithPremium()
                }
            }
        }
    }
    
    private func setPremiumUI() {
        self.initialsLabel.isHidden = false
        self.starImageView.isHidden = false
        self.avatarImageView.isHidden = true
        self.stackViewLeadingConstraint?.constant = 10
        self.stackViewTrailingConstraint?.constant = -10
    }
    
    private func setAuthorizedWithoutPremiumUI() {
        self.initialsLabel.isHidden = false
        self.starImageView.isHidden = true
        self.avatarImageView.isHidden = true
        self.stackViewLeadingConstraint?.constant = 0
        self.stackViewTrailingConstraint?.constant = 0
    }
    
    private func setUnauthorizedUI() {
        self.initialsLabel.isHidden = true
        self.starImageView.isHidden = true
        self.avatarImageView.isHidden = false
        self.stackViewLeadingConstraint?.constant = 0
        self.stackViewTrailingConstraint?.constant = 0
    }
    
    private func setUnauthorizedUIWithPremium() {
        self.initialsLabel.isHidden = true
        self.starImageView.isHidden = false
        self.avatarImageView.isHidden = false
        self.stackViewLeadingConstraint?.constant = 10
        self.stackViewTrailingConstraint?.constant = 0
    }
    
    private func addingViews() {
        self.stackView.addArrangedSubview(self.starImageView)
        self.stackView.addArrangedSubview(self.initialsLabel)
        self.stackView.addArrangedSubview(self.avatarImageView)
        self.addSubview(self.stackView)
    }
    
    private func setupConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.stackViewLeadingConstraint = self.stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        self.stackViewLeadingConstraint?.isActive = true
        self.stackViewTrailingConstraint = self.stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        self.stackViewTrailingConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            self.stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            self.stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            self.stackView.heightAnchor.constraint(equalToConstant: 40),
            
            self.starImageView.heightAnchor.constraint(equalToConstant: 16),
            self.starImageView.widthAnchor.constraint(equalToConstant: 16),
            
            self.avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            self.avatarImageView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func applyTheme(currentTheme: Theme) {
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.whiteColor.cgColor
        switch currentTheme.type {
        case .dark:
            self.avatarImageView.image = UIImage(named: "img_avatar_icon_dark")
            self.backgroundColor = .black
            self.starImageView.image = UIImage(named: "img_premium_star_dark")
            self.initialsLabel.textColor = UIColor.white
        case .light:
            self.avatarImageView.image = UIImage(named: "img_avatar_icon_light")
            self.backgroundColor = .white
            self.starImageView.image = UIImage(named: "img_premium_star_light")
            self.initialsLabel.textColor = UIColor.onboardingTitleDark
        }
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        self.tapClosure?()
    }
}
