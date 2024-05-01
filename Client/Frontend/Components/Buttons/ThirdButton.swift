// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Common

class ThirdButton: BaseTouchableButton, Themeable {
    var themeManager: ThemeManager
    var notificationCenter: NotificationProtocol
    var themeObserver: NSObjectProtocol?
    
    private var heightConstraint: NSLayoutConstraint!
    
    private let heightDefaultValue: CGFloat = 56
    
    private let activityIndicator = BaseActivityIndicator(activityIndicatorSize: .small)
    
    var height: CGFloat {
        get { return self.heightConstraint.constant }
        set { self.heightConstraint.constant = newValue }
    }
    
    private var savedText: String?
    private var savedAttributedText: NSAttributedString?
    
    override var isEnabled: Bool {
        didSet {
            self.applyTheme()
        }
    }
    
    init(themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default) {
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        super.init(frame: .zero)
        self.commonInit()
        self.setupConstraints()
        
        self.listenForThemeChange(self)
        self.applyTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4
        self.titleLabel?.font = .sourceSansProFont(.semiBold, size: 18)
    }
    
    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: heightDefaultValue)
        self.heightConstraint.isActive = true
    }
    
    func applyTheme() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicator.applyTheme(currentTheme: self.themeManager.currentTheme)
            
            switch self.isEnabled {
            case true:
                self.backgroundColor = self.themeManager.currentTheme.type == .dark ? UIColor.neutralsGray01 : UIColor.neutralsGray06
                
                let titleColor = self.themeManager.currentTheme.type == .dark ? UIColor.white : UIColor.black
                self.setTitleColor(titleColor, for: .normal)
                
                self.layer.borderWidth = 0
                self.layer.borderColor = nil
            case false:
                self.backgroundColor = self.themeManager.currentTheme.type == .dark ? UIColor.neutralsGray01.withAlphaComponent(0.5) : UIColor.neutralsGray06.withAlphaComponent(0.5)
                
                self.setTitleColor(UIColor.black, for: .normal)
                
                self.layer.borderWidth = 0
                self.layer.borderColor = nil
            }
        }
    }
    
    func startIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let attributedText = self.currentAttributedTitle {
                self.savedAttributedText = attributedText
                self.setAttributedTitle(nil, for: .normal)
            } else {
                self.savedText = self.titleLabel?.text ?? ""
                self.setTitle("", for: .normal)
            }
            self.activityIndicator.applyTheme(currentTheme: self.themeManager.currentTheme)
            self.activityIndicator.start(pinToView: self, overlayMode: .transparent)
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stop(completion: {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if let savedAttributedText = self.savedAttributedText {
                        self.setAttributedTitle(savedAttributedText, for: .normal)
                    } else {
                        self.setTitle(self.savedText, for: .normal)
                    }
                }
            })
        }
    }
}
