// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

protocol CustomTextFieldWithErrorMessageDelegate: AnyObject {
    func textFieldShouldReturn(_ sender: CustomTextFieldWithErrorMessage) -> Bool
    func textFieldDidBeginEditing(_ sender: CustomTextFieldWithErrorMessage)
    func textFieldEditingChanged(_ sender: CustomTextFieldWithErrorMessage)
    func textFieldDidEndEditing(_ sender: CustomTextFieldWithErrorMessage)
}

class CustomTextFieldWithErrorMessage: UIView {
    // MARK: - Properties
    
    enum FieldType {
        case general
        case email
        case password
    }
    
    weak var delegate: CustomTextFieldWithErrorMessageDelegate?
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 4
        return sv
    }()
    
    var textField: CustomTextField!
    
    private var lblError: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.textColor = UIColor.redHomeToolbar
        lbl.font = UIFont.sourceSansProFont(.regular, size: 12)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.isUserInteractionEnabled = false
        return lbl
    }()
    
    var errorMessage: String = "" {
        didSet {
            self.updateUI()
        }
    }
    
    private var currentTheme: Theme?
    
    // MARK: - Initialization
    
    init(currentTheme: Theme?, fieldType: FieldType) {
        self.currentTheme = currentTheme
        switch fieldType {
        case .general:
            self.textField = CustomTextField()
        case .email:
            self.textField = EmailTextField()
        case .password:
            self.textField = PasswordTextField()
        }
        super.init(frame: .zero)
        
        self.addingViews()
        self.setupConstraints()
        self.textField.tintColor = self.currentTheme?.type == .dark ? UIColor.white : UIColor.blackColor
        self.textField.textColor = self.currentTheme?.type == .dark ? UIColor.white : UIColor.blackColor
        self.textField.backgroundColor = self.currentTheme?.type == .dark ? UIColor.clear : UIColor.white
        self.textField.delegate = self
        self.setTargets()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
    
    private func addingViews() {
        self.stackView.addArrangedSubview(self.textField)
        self.addSubview(self.stackView)
    }
    
    private func setupConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.textField.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    private func setTargets() {
        self.textField.addTarget(self, action: #selector(self.didBeginEditing(_:)), for: .editingDidBegin)
        self.textField.addTarget(self, action: #selector(self.editingChanged(_:)), for: .editingChanged)
        self.textField.addTarget(self, action: #selector(self.didEndEditing(_:)), for: .editingDidEnd)
    }
    
    // MARK: TextFields targets
    
    @objc private func didBeginEditing(_ sender: UITextField) {
        self.delegate?.textFieldDidBeginEditing(self)
    }
    
    @objc private func editingChanged(_ sender: UITextField) {
        self.errorMessage = ""
        self.delegate?.textFieldEditingChanged(self)
    }
    
    @objc private func didEndEditing(_ sender: UITextField) {
        self.delegate?.textFieldDidEndEditing(self)
    }
    
    // MARK: - Public Methods
    
    func setIcon(_ image: UIImage?) {
        self.textField.setIcon(image)
    }
    
    func setPlaceholder(_ placeholderText: String) {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.whiteColor
        ]
        let attributedText = NSAttributedString(string: placeholderText, attributes: attributes)
        self.textField.attributedPlaceholder = attributedText
    }
    
    func getText() -> String? {
        return self.textField.text
    }
    
    private func updateUI() {
        self.lblError.text = self.errorMessage
        if !self.errorMessage.isEmpty {
            if self.lblError.superview == nil {
                self.stackView.addArrangedSubview(self.lblError)
            }
        } else {
            self.stackView.removeArrangedSubview(self.lblError)
            self.lblError.removeFromSuperview()
        }
    }
}

extension CustomTextFieldWithErrorMessage: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.delegate?.textFieldShouldReturn(self) ?? true
    }
}
