// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import Shared

protocol SignUpContentViewDelegate: AnyObject {
    func enteredDataUpdated()
    func keyboardWillShowWithHeight(_ height: CGFloat, notification: NSNotification)
    func keyboardWillHide()
}

class SignUpContentView: UIView {
    weak var delegate: SignUpContentViewDelegate?
    
    private lazy var topTitleView = OnboardingTopTitleView()
    
    private var lineView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var signUpInfoStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 16
        return sv
    }()
    
    lazy var signInWithAppleItem = SignInWithAppleItemView()
    lazy var orViewItem = AuthOrView()
    
    lazy var firstNameItem: CustomTextFieldWithErrorMessage = {
        let field = CustomTextFieldWithErrorMessage(fieldType: .general)
        field.setPlaceholder("First Name")
        field.delegate = self
        return field
    }()
    
    lazy var lastNameItem: CustomTextFieldWithErrorMessage = {
        let field = CustomTextFieldWithErrorMessage(fieldType: .general)
        field.setPlaceholder("Last Name")
        field.delegate = self
        return field
    }()
    
    lazy var emailItem: CustomTextFieldWithErrorMessage = {
        let field = CustomTextFieldWithErrorMessage(fieldType: .email)
        field.setPlaceholder("Your Email")
        field.delegate = self
        return field
    }()
    
    lazy var passwordItem: CustomTextFieldWithErrorMessage = {
        let field = CustomTextFieldWithErrorMessage(fieldType: .password)
        field.setPlaceholder("Password")
        field.delegate = self
        return field
    }()
    
    var activeTextField: CustomTextFieldWithErrorMessage?
    
    required init() {
        super.init(frame: .zero)
        
        self.addingViews()
        self.setupConstraints()
        self.addKeyboardNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyTheme(currentTheme: Theme) {
        self.topTitleView.applyTheme(currentTheme: currentTheme)
        self.signInWithAppleItem.applyTheme(currentTheme: currentTheme)
        self.orViewItem.applyTheme(currentTheme: currentTheme)
        
        // firstNameItem
        let firstNameItemImage = currentTheme.type == .dark ? UIImage(named: "img_first_name_field_icon_dark") : UIImage(named: "img_first_name_field_icon_light")
        self.firstNameItem.setIcon(firstNameItemImage)
        self.firstNameItem.applyTheme(currentTheme: currentTheme)
        
        // lastNameItem
        let lastNameItemImage = currentTheme.type == .dark ? UIImage(named: "img_first_name_field_icon_dark") : UIImage(named: "img_first_name_field_icon_light")
        self.lastNameItem.setIcon(lastNameItemImage)
        self.lastNameItem.applyTheme(currentTheme: currentTheme)
        
        // emailItem
        let emailItemImage = currentTheme.type == .dark ? UIImage(named: "img_email_field_icon_dark") : UIImage(named: "img_email_field_icon_light")
        self.emailItem.setIcon(emailItemImage)
        self.emailItem.applyTheme(currentTheme: currentTheme)
        
        // passwordItem
        let passwordItemImage = currentTheme.type == .dark ? UIImage(named: "img_password_field_icon_dark") : UIImage(named: "img_password_field_icon_light")
        self.passwordItem.setIcon(passwordItemImage)
        self.passwordItem.applyTheme(currentTheme: currentTheme)
        
        self.backgroundColor = .clear
        
        switch currentTheme.type {
        case .dark:
            self.lineView.backgroundColor = UIColor.blackColor
        case .light:
            self.lineView.backgroundColor = UIColor.whiteColor
        }
    }
    
    private func addingViews() {
        self.addSubview(self.topTitleView)
        self.addSubview(self.lineView)
        self.addSubview(self.signUpInfoStackView)
        self.addItems()
    }
    
    private func addItems() {
        self.signUpInfoStackView.addArrangedSubview(self.signInWithAppleItem)
        self.signUpInfoStackView.addArrangedSubview(self.orViewItem)
        self.signUpInfoStackView.addArrangedSubview(self.firstNameItem)
        self.signUpInfoStackView.addArrangedSubview(self.lastNameItem)
        self.signUpInfoStackView.addArrangedSubview(self.emailItem)
        self.signUpInfoStackView.addArrangedSubview(self.passwordItem)
    }
    
    private func setupConstraints() {
        self.topTitleView.translatesAutoresizingMaskIntoConstraints = false
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.signUpInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topTitleView.topAnchor.constraint(equalTo: self.topAnchor, constant: UIDevice.current.isPad ? 120 : 105),
            self.topTitleView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            self.topTitleView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            self.topTitleView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            
            self.lineView.topAnchor.constraint(equalTo: self.topTitleView.bottomAnchor, constant: UIDevice.current.isPad ? 40 : 16),
            self.lineView.heightAnchor.constraint(equalToConstant: 1),
            self.lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.signUpInfoStackView.topAnchor.constraint(equalTo: self.lineView.bottomAnchor, constant: 32),
            self.signUpInfoStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: UIDevice.current.isPad ? 80 : 40),
            self.signUpInfoStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: UIDevice.current.isPad ? -80 : -40),
            self.signUpInfoStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -32)
        ])
    }
    
    func configure(lblTitleText: String, lblSubtitleText: String?) {
        self.topTitleView.configure(lblTitleText: lblTitleText,
                                    lblSubtitleText: lblSubtitleText,
                                    logoIsHidden: false)
    }
}

// MARK: CustomTextFieldWithErrorMessageDelegate

extension SignUpContentView: CustomTextFieldWithErrorMessageDelegate {
    func textFieldShouldReturn(_ textField: CustomTextFieldWithErrorMessage) -> Bool {
        self.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ sender: CustomTextFieldWithErrorMessage) {
        self.signInWithAppleItem.errorMessage = ""
        self.activeTextField = sender
    }
    
    func textFieldEditingChanged(_ sender: CustomTextFieldWithErrorMessage) {
        
    }
    
    func textFieldDidEndEditing(_ sender: CustomTextFieldWithErrorMessage) {
        self.activeTextField = nil
        
        if sender == self.firstNameItem {
            let validationResult = Validator.validateFirstName(self.firstNameItem.getText())
            if case .invalid(let errorMessage) = validationResult {
                self.firstNameItem.errorMessage = errorMessage
            }
        } else if sender == self.lastNameItem {
            let validationResult = Validator.validateLastName(self.lastNameItem.getText())
            if case .invalid(let errorMessage) = validationResult {
                self.lastNameItem.errorMessage = errorMessage
            }
        } else if sender == self.emailItem {
            let validationResult = Validator.validateEmail(self.emailItem.getText())
            if case .invalid(let errorMessage) = validationResult {
                self.emailItem.errorMessage = errorMessage
            }
        } else if sender == self.passwordItem {
            let validationResult = Validator.validatePassword(self.passwordItem.getText())
            if case .invalid(let errorMessage) = validationResult {
                self.passwordItem.errorMessage = errorMessage
            }
        }
        
        self.delegate?.enteredDataUpdated()
    }
}

extension SignUpContentView {
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    @objc private func keyboardNotification(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return}
        let keyboardFrame = keyboardSize.cgRectValue
        
        let duration: TimeInterval = (userInfo[
            UIResponder.keyboardAnimationDurationUserInfoKey
        ] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        if keyboardFrame.origin.y >= UIScreen.main.bounds.size.height {
            // MARK: Keyboard will hide
            self.delegate?.keyboardWillHide()
        } else {
            // MARK: Keyboard will show with height keyboardFrame.size.height
            self.delegate?.keyboardWillShowWithHeight(keyboardFrame.size.height, notification: notification)
        }
        
        UIView.animate(withDuration: duration,
                       delay: TimeInterval(0),
                       options: animationCurve,
                       animations: {
            self.superview?.layoutIfNeeded()
        },
                       completion: nil)
    }
}
