// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Kingfisher

class StorySummaryOverlayView: UIView {
    // MARK: - Properties
    
    private let btnReadMore: UIButton = {
        let button = UIButton()
        button.setTitle("Read more", for: .normal)
        button.titleLabel?.font = UIFont.sourceSansProFont(.regular, size: 15)
        
        button.layer.masksToBounds = true
        
        button.layer.borderWidth = 1
        
        button.layer.borderColor = UIColor.neutralsGray04.cgColor
        button.setTitleColor(UIColor.neutralsGray01, for: .normal)
        button.backgroundColor = UIColor.neutralsGray05
        
        button.layer.cornerRadius = 4
        return button
    }()
    
    private var currentTheme: Theme?
    
    var btnReadMoreTappedClosure: (() -> Void)?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupGradientLayer()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.clear
        self.addSubviews()
        self.addSubviewsConstraints()
        self.btnReadMore.addTarget(self, action: #selector(self.btnReadMoreTapped), for: .touchUpInside)
    }
    
    // MARK: - Setup Methods
    
    private func addSubviews() {
        self.addSubview(self.btnReadMore)
    }
    
    private func addSubviewsConstraints() {
        self.btnReadMore.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.btnReadMore.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.btnReadMore.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            self.btnReadMore.heightAnchor.constraint(equalToConstant: 30),
            self.btnReadMore.widthAnchor.constraint(equalToConstant: 123)
        ])
    }
    
    private func setupGradientLayer() {
        let locations: [NSNumber] = [0.0, 0.25, 1.0]
        
        let lightThemeColors = [UIColor.neutralsGray07.withAlphaComponent(0.01).cgColor,
                                UIColor.neutralsGray07.withAlphaComponent(0.7).cgColor,
                                UIColor.neutralsGray07.cgColor]
        
        let darkThemeColors = [UIColor.darkBackground.withAlphaComponent(0.01).cgColor,
                               UIColor.darkBackground.withAlphaComponent(0.7).cgColor,
                               UIColor.darkBackground.cgColor]
        
        if self.currentTheme?.type == .dark {
            self.setGradient(locations: locations,
                             colors: darkThemeColors)
        } else {
            self.setGradient(locations: locations,
                             colors: lightThemeColors)
        }
    }
    
    func applyTheme(currentTheme: Theme) {
        self.currentTheme = currentTheme
        
        switch currentTheme.type {
        case .light:
            self.btnReadMore.layer.borderColor = UIColor.neutralsGray04.cgColor
            self.btnReadMore.setTitleColor(UIColor.neutralsGray01, for: .normal)
            self.btnReadMore.backgroundColor = UIColor.neutralsGray05
        case .dark:
            self.btnReadMore.layer.borderColor = UIColor.neutralsGray02.cgColor
            self.btnReadMore.setTitleColor(UIColor.white, for: .normal)
            self.btnReadMore.backgroundColor = UIColor.darkBackground
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    @objc private func btnReadMoreTapped() {
        self.btnReadMoreTappedClosure?()
    }
}

// MARK: - Hit Test

extension StorySummaryOverlayView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let convertedPoint = self.convert(point, to: self.btnReadMore)
        return self.btnReadMore.point(inside: convertedPoint, with: event) ? self.btnReadMore : super.hitTest(point, with: event)
    }
}
