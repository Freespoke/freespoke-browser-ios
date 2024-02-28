// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class CustomTitleView: UIView {
    // MARK: - Properties
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.sourceSansProFont(.bold, size: 16)
        return button
    }()
    private var currentTheme: Theme?
    
    private let profileIconView: ProfileIconView = {
        let profileIconView = ProfileIconView()
        return profileIconView
    }()

    // MARK: Closures
    
    var backButtonTapClosure: (() -> Void)?
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        setupUI()
        backButton.addTarget(self, action: #selector(self.backButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    func setCurrentTheme(currentTheme: Theme) {
        self.currentTheme = currentTheme
        self.applyTheme()
        self.profileIconView.configureTheme(currentTheme: currentTheme)
    }
    
    func updateProfileIcon(freespokeJWTDecodeModel: FreespokeJWTDecodeModel?) {
        self.profileIconView.updateView(decodedJWTToken: freespokeJWTDecodeModel)
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            self.backgroundColor = .clear
            
            switch theme.type {
            case .dark:
                self.backButton.setTitleColor(.whiteColor, for: .normal)
                self.backButton.setImage(UIImage(named: "left_arrow")?.withTintColor(.whiteColor, renderingMode: .alwaysOriginal), for: .normal)
            case .light:
                self.backButton.setTitleColor(.blackColor, for: .normal)
                self.backButton.setImage(UIImage(named: "left_arrow")?.withTintColor(.blackColor, renderingMode: .alwaysOriginal), for: .normal)
            }
        }
    }
        
    private func setupUI() {
        addSubview(backButton)
        addSubview(profileIconView)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        profileIconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileIconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            profileIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    // MARK: - Button Actions
    
    @objc private func backButtonTapped() {
        self.backButtonTapClosure?()
    }
}
