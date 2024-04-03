// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class BaseButton: UIButton {
    private var style: BaseButtonStyle = .greenStyle(currentTheme: nil)
    
    private var heightConstraint: NSLayoutConstraint!
    
    private let heightDefaultValue: CGFloat = 56
    
    private let activityIndicator = BaseActivityIndicator(activityIndicatorSize: .small)
    
    var height: CGFloat {
        get { return self.heightConstraint.constant }
        set { self.heightConstraint.constant = newValue }
    }
    
    private var text = ""
    
    override var isEnabled: Bool {
        didSet {
            self.setStyle(style: self.style)
        }
    }
    
    init(style: BaseButtonStyle) {
        self.style = style
        super.init(frame: .zero)
        self.commonInit()
        self.setupConstraints()
        self.setStyle(style: self.style)
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        self.commonInit()
        self.setupConstraints()
        self.setStyle(style: self.style)
    }
    
    private func commonInit() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4
    }
    
    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: heightDefaultValue)
        self.heightConstraint.isActive = true
    }
    
    func setStyle(style: BaseButtonStyle) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.style = style
            
            self.titleLabel?.font = style.settings.font
            
            switch self.isEnabled {
            case true:
                self.backgroundColor = self.style.settings.backgroundColorEnableState
                self.setTitleColor(self.style.settings.fontColorEnableState, for: .normal)
                
                if let borderWidth = self.style.settings.borderWidthEnableState {
                    self.layer.borderWidth = borderWidth
                    self.layer.borderColor = self.style.settings.borderColorEnableState
                }
            case false:
                self.backgroundColor = self.style.settings.backgroundColorNotEnableState
                self.setTitleColor(self.style.settings.fontColorNotEnableState, for: .normal)
                
                if let borderWidth = self.style.settings.borderWidthDisabledState {
                    self.layer.borderWidth = borderWidth
                    self.layer.borderColor = self.style.settings.borderColorNotEnableState
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .curveLinear,
                           animations: { [weak self] in
                self?.alpha = 0.75
                self?.titleLabel?.alpha = 0.5
            }, completion: nil)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: { [weak self] in
                self?.alpha = 1
                self?.titleLabel?.alpha = 1
            })
        }
    }
    
    func startIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.text = sSelf.titleLabel?.text ?? ""
            sSelf.setTitle("", for: .normal)
            sSelf.activityIndicator.activityIndicatorColor = sSelf.style.settings.activityIndicatorColor
            sSelf.activityIndicator.start(pinToView: sSelf)
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.activityIndicator.stop(completion: {
                DispatchQueue.main.async { [weak self] in
                    guard let sSelf = self else { return }
                    sSelf.setTitle(sSelf.text, for: .normal)
                }
            })
        }
    }
}
