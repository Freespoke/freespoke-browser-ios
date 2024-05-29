// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

final class DomainTxtCell: UITableViewCell {
    static let reuseIdentifier = String(describing: type(of: DomainTxtCell.self))
    
    var txtDidEndEditingClosure: ((_ text: String?) -> Void)?
    var txtFieldTextChangedClosure: ((_ text: String?) -> Void)?
    
    private let borderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.whiteColor.cgColor
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private let txtField: UITextField = {
        let txt = UITextField()
        txt.font = UIFont.sourceSansProFont(.regular, size: 14)
        txt.autocapitalizationType = .none
        txt.autocorrectionType = .no
        return txt
    }()
    
    private var currentTheme: Theme?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
        self.addTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareUI() {
        self.selectionStyle = .none
        self.txtField.delegate = self
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
    }
    
    private func addingViews() {
        self.contentView.addSubview(self.borderView)
        self.borderView.addSubview(self.txtField)
    }
    
    private func setupConstraints() {
        self.txtField.translatesAutoresizingMaskIntoConstraints = false
        
        self.borderView.pinToView(view: self.contentView, withInsets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
        
        NSLayoutConstraint.activate([
            self.txtField.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: 10),
            self.txtField.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor, constant: 12),
            self.txtField.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -12),
            self.txtField.bottomAnchor.constraint(equalTo: self.borderView.bottomAnchor, constant: -10)
        ])
    }
    
    func setData(placeholder: String, domain: String?, currentTheme: Theme?) {
        self.currentTheme = currentTheme
        self.txtField.placeholder = placeholder
        self.txtField.text = domain
        self.applyTheme()
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            self.borderView.layer.borderColor = (theme.type == .light) ? UIColor.whiteColor.cgColor : UIColor.blackColor.cgColor
            self.borderView.backgroundColor = (theme.type == .light) ? UIColor.white : UIColor.clear
        }
    }
    
    private func addTargets() {
        self.txtField.addTarget(self,
                                action: #selector(self.txtFieldTextChanged),
                                for: .editingChanged)
    }
    
    @objc private func txtFieldTextChanged() {
        self.txtFieldTextChangedClosure?(self.txtField.text)
    }
}

extension DomainTxtCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.txtDidEndEditingClosure?(textField.text)
    }
}
