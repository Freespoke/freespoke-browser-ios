// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class OnboardingBottomButtonsView: UIView {
    private var btnsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 32
        sv.layer.masksToBounds = true
        sv.clipsToBounds = false
        return sv
    }()
    
    private var currentTheme: Theme?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addingViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.addingViews()
        self.setupConstraints()
    }
    
    private func addingViews() {
        self.addSubview(self.btnsStackView)
    }
    
    private func setupConstraints() {
        btnsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            btnsStackView.topAnchor.constraint(equalTo: self.self.topAnchor, constant: 32),
            btnsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            btnsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            btnsStackView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])
    }
    
    func addViews(views: [UIView]) {
        views.forEach({ [weak self] in
            self?.btnsStackView.addArrangedSubview($0)
        })
    }
    
    func configure(currentTheme: Theme?) {
        self.currentTheme = currentTheme
        self.applyTheme()
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            switch theme.type {
            case .dark:
                self.backgroundColor = .black
            case .light:
                self.backgroundColor = theme.colors.layer1
            }
        }
    }
    
    func updateButtonsSpacing(to value: CGFloat) {
        self.btnsStackView.spacing = value
    }
}
