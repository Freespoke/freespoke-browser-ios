// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class PasswordTextField: CustomTextField {
    private var btnShowHidePassword = UIButton()
    
    override init(padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 50)) {
        super.init(padding: padding)
        self.commonInit()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.returnKeyType = UIReturnKeyType.default
        self.spellCheckingType = .no
        self.autocapitalizationType = .none
        self.smartQuotesType = .no
        self.textContentType = .password
        self.autocorrectionType = .no
        self.rightViewMode = .always
        self.isSecureTextEntry = true
        self.setupBtnShowHidePassword()
    }
    
    private func setupBtnShowHidePassword() {
        var filled = UIButton.Configuration.filled()
        filled.image = UIImage(named: "img_show_password")
        filled.imagePadding = 10
        filled.baseBackgroundColor = .clear
        self.btnShowHidePassword = UIButton(configuration: filled, primaryAction: nil)
        self.btnShowHidePassword.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.btnShowHidePassword.addTarget(self, action: #selector(self.btnShowHidePasswordTapped(_:)), for: UIControl.Event.touchUpInside)
        self.rightView = self.btnShowHidePassword
    }
    
    @objc private func btnShowHidePasswordTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.isSecureTextEntry = false
            self.btnShowHidePassword.setImage(UIImage(named: "img_hide_password"), for: .normal)
        } else {
            self.isSecureTextEntry = true
            self.btnShowHidePassword.setImage(UIImage(named: "img_show_password"), for: .normal)
        }
    }
}
