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
    
    private let profileIconView: ProfileIconView = {
        let profileIconView = ProfileIconView()
        return profileIconView
    }()
    
    // MARK: Closures
    
    var backButtonTappedClosure: (() -> Void)?
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        self.addingViews()
        self.setupConstraints()
        self.backButton.addTarget(self, action: #selector(self.backButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    func updateProfileIcon(freespokeJWTDecodeModel: FreespokeJWTDecodeModel?) {
        self.profileIconView.updateView(decodedJWTToken: freespokeJWTDecodeModel)
    }
    
    func applyTheme(currentTheme: Theme) {
        self.profileIconView.applyTheme(currentTheme: currentTheme)
        
        self.backgroundColor = .clear
        
        switch currentTheme.type {
        case .dark:
            self.backButton.setTitleColor(.whiteColor, for: .normal)
            self.backButton.setImage(UIImage(named: "left_arrow")?.withTintColor(.whiteColor, renderingMode: .alwaysOriginal), for: .normal)
        case .light:
            self.backButton.setTitleColor(.blackColor, for: .normal)
            self.backButton.setImage(UIImage(named: "left_arrow")?.withTintColor(.blackColor, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    private func addingViews() {
        self.addSubview(self.backButton)
        self.addSubview(self.profileIconView)
    }
    
    private func setupConstraints() {
        self.backButton.translatesAutoresizingMaskIntoConstraints = false
        self.profileIconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.profileIconView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 40),
            
            self.profileIconView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.profileIconView.topAnchor.constraint(equalTo: self.topAnchor),
            self.profileIconView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    // MARK: - Button Actions
    
    @objc private func backButtonTapped() {
        self.backButtonTappedClosure?()
    }
}
