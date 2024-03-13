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
    
    private var iconImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "onboarding_logo_torch")
        imgView.contentMode = .scaleToFill
        return imgView
    }()
    
    private var labelsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = UIDevice.current.isPad ? 32 : 8
        return sv
    }()
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = UIColor.onboardingTitleDark
        lbl.font = UIFont.sourceSerifProFontFont(.semiBold, size: 28)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private var lblSubtitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = UIColor.blackColor
        lbl.font = UIFont.sourceSansProFont(.regular, size: 16)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
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
    
    lazy var signInWithAppleItem = SignInWithAppleItemView(currentTheme: self.currentTheme)
    lazy var orViewItem = AuthOrView(currentTheme: self.currentTheme)
    
    lazy var firstNameItem: CustomTextFieldWithErrorMessage = {
        let field = CustomTextFieldWithErrorMessage(currentTheme: self.currentTheme, fieldType: .general)
        let image = self.currentTheme?.type == .dark ? UIImage(named: "img_first_name_field_icon_dark") : UIImage(named: "img_first_name_field_icon_light")
        field.setIcon(image)
        field.setPlaceholder("First Name")
        field.delegate = self
        return field
    }()
    
    lazy var lastNameItem: CustomTextFieldWithErrorMessage = {
        let field = CustomTextFieldWithErrorMessage(currentTheme: self.currentTheme, fieldType: .general)
        let image = self.currentTheme?.type == .dark ? UIImage(named: "img_first_name_field_icon_dark") : UIImage(named: "img_first_name_field_icon_light")
        field.setIcon(image)
        field.setPlaceholder("Last Name")
        field.delegate = self
        return field
    }()
    
    lazy var emailItem: CustomTextFieldWithErrorMessage = {
        let field = CustomTextFieldWithErrorMessage(currentTheme: self.currentTheme, fieldType: .email)
        let image = self.currentTheme?.type == .dark ? UIImage(named: "img_email_field_icon_dark") : UIImage(named: "img_email_field_icon_light")
        field.setIcon(image)
        field.setPlaceholder("Your Email")
        field.delegate = self
        return field
    }()
    
    lazy var passwordItem: CustomTextFieldWithErrorMessage = {
        let field = CustomTextFieldWithErrorMessage(currentTheme: self.currentTheme, fieldType: .password)
        let image = self.currentTheme?.type == .dark ? UIImage(named: "img_password_field_icon_dark") : UIImage(named: "img_password_field_icon_light")
        field.setIcon(image)
        field.setPlaceholder("Password")
        field.delegate = self
        return field
    }()
    
    var activeTextField: CustomTextFieldWithErrorMessage?
    
    private var currentTheme: Theme?
    
    required init(currentTheme: Theme?) {
        self.currentTheme = currentTheme
        super.init(frame: .zero)
        
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
        self.addKeyboardNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareUI() {
        self.applyTheme()
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            self.backgroundColor = .clear
            
            switch theme.type {
            case .dark:
                self.lblTitle.textColor = UIColor.whiteColor
                self.lblSubtitle.textColor = UIColor.whiteColor
                self.lineView.backgroundColor = UIColor.blackColor
            case .light:
                self.lblTitle.textColor = UIColor.blackColor
                self.lblSubtitle.textColor = UIColor.blackColor
                self.lineView.backgroundColor = UIColor.whiteColor
            }
        }
    }
    
    private func addingViews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.labelsStackView)
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
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.signUpInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.iconImageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 50),
            self.iconImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 32),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 32),
            
            self.labelsStackView.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor, constant: 8),
            self.labelsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            self.labelsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            
            self.lineView.topAnchor.constraint(equalTo: self.labelsStackView.bottomAnchor, constant: UIDevice.current.isPad ? 40 : 16),
            self.lineView.heightAnchor.constraint(equalToConstant: 1),
            self.lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.signUpInfoStackView.topAnchor.constraint(equalTo: self.lineView.bottomAnchor, constant: 32),
            self.signUpInfoStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: UIDevice.current.isPad ? 80 : 40),
            self.signUpInfoStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: UIDevice.current.isPad ? -80 : -40),
            self.signUpInfoStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -32)
        ])
    }
    
    func configure(currentTheme: Theme?, lblTitleText: String, lblSubtitleText: String?) {
        self.labelsStackView.arrangedSubviews.forEach({ [weak self] in
            guard let self = self else { return }
            self.labelsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        
        self.lblTitle.text = lblTitleText
        self.labelsStackView.addArrangedSubview(self.lblTitle)
        
        if let subtitleText = lblSubtitleText {
            self.lblSubtitle.text = subtitleText
            self.labelsStackView.addArrangedSubview(self.lblSubtitle)
        }
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
