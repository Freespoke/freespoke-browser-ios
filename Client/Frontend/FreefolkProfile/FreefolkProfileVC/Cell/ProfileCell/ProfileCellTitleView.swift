// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class ProfileCellTitleView: UIView {
    // MARK: - Properties
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.sourceSansProFont(.semiBold, size: 19)
        label.textColor = .blackColor
        return label
    }()
    
    private let warningImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "img_warning")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let warningButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        return button
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: Closures
    
    var warningButtonTappedClosure: (() -> Void)?
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        self.setupUI()
        self.addingViews()
        self.setupConstraints()
        self.warningButton.addTarget(self, action: #selector(self.warningButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        self.backgroundColor = .clear
    }
    
    private func addingViews() {
        self.contentStackView.addArrangedSubview(self.titleLabel)
        self.addSubview(self.contentStackView)
    }
    
    private func setupConstraints() {
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            self.contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -5)
        ])
    }
    
    private func addWarningView() {
        ensureMainThread { [weak self] in
            guard let self = self else { return }
            guard self.warningButton.superview == nil else { return }
            guard self.warningImageView.superview == nil else { return }
            
            self.warningImageView.addSubview(self.warningButton)
            self.contentStackView.addArrangedSubview(self.warningImageView)
            
            self.warningImageView.translatesAutoresizingMaskIntoConstraints = false
            self.warningButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.warningImageView.heightAnchor.constraint(equalToConstant: 20),
                self.warningImageView.widthAnchor.constraint(equalToConstant: 20),
                
                self.warningButton.centerYAnchor.constraint(equalTo: self.warningImageView.centerYAnchor),
                self.warningButton.centerXAnchor.constraint(equalTo: self.warningImageView.centerXAnchor),
                self.warningButton.heightAnchor.constraint(equalToConstant: 44),
                self.warningButton.widthAnchor.constraint(equalToConstant: 44)
            ])
        }
    }
    
    func hideWarningView() {
        ensureMainThread { [weak self] in
            guard let self = self else { return }
            self.warningImageView.removeFromSuperview()
            self.warningButton.removeFromSuperview()
        }
    }
    
    func showWarningView() {
        self.addWarningView()
    }
    
    // MARK: - Button Actions
    
    @objc private func warningButtonTapped() {
        self.warningButtonTappedClosure?()
    }
}
