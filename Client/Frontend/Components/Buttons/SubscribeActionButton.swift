// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Common

class SubscribeActionButton: BaseTouchableButton, Themeable {
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
    
    private var savedMainLeftTitleText: String?
    private var savedText: String?
    private var savedAttributedText: NSAttributedString?
    
    override var isEnabled: Bool {
        didSet {
            self.applyTheme()
        }
    }
    
    private var mainLeftTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.textColor = UIColor.blackColor
        lbl.font = UIFont.sourceSansProFont(.bold, size: 18)
        lbl.isUserInteractionEnabled = false
        lbl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return lbl
    }()
    
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
        self.titleLabel?.textAlignment = .right
        
        self.addSubviews(self.mainLeftTitleLabel)
    }
    
    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.mainLeftTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: heightDefaultValue)
        self.heightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            self.mainLeftTitleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.mainLeftTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.mainLeftTitleLabel.widthAnchor.constraint(equalToConstant: 120)
        ])
        
        if let titleLabel = self.titleLabel {
            titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            NSLayoutConstraint.activate([
                titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
                titleLabel.leadingAnchor.constraint(equalTo: self.mainLeftTitleLabel.trailingAnchor, constant: 10)
            ])
        }
    }
    
    func applyTheme() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicator.applyTheme(currentTheme: self.themeManager.currentTheme)
            
            switch self.isEnabled {
            case true:
                self.backgroundColor = self.themeManager.currentTheme.type == .dark ? UIColor.greenColor : UIColor.greenColor
                
                self.setTitleColor(UIColor.white, for: .normal)
                self.mainLeftTitleLabel.textColor = UIColor.white
                
                self.layer.borderWidth = 0
                self.layer.borderColor = nil
            case false:
                self.backgroundColor = self.themeManager.currentTheme.type == .dark ? UIColor.greenColor.withAlphaComponent(0.5) : UIColor.greenColor.withAlphaComponent(0.5)
                self.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
                self.mainLeftTitleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
                
                self.layer.borderWidth = 0
                self.layer.borderColor = nil
            }
        }
    }
    
    func startIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.savedMainLeftTitleText = self.mainLeftTitleLabel.text
            self.mainLeftTitleLabel.text = nil
            
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
                    self.mainLeftTitleLabel.text = self.savedMainLeftTitleText
                    if let savedAttributedText = self.savedAttributedText {
                        self.setAttributedTitle(savedAttributedText, for: .normal)
                    } else {
                        self.setTitle(self.savedText, for: .normal)
                    }
                }
            })
        }
    }
    
    func setMainLableTitle(text: String) {
        self.mainLeftTitleLabel.text = text
    }
}
