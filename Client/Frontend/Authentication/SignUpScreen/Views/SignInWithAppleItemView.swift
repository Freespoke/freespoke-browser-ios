// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class SignInWithAppleItemView: UIStackView {
    private lazy var btnSignInWithApple = SignInWithAppleButton()
    
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
    
    var tapClosure: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        
        self.axis = .vertical
        self.spacing = 5
        self.addingViews()
        self.setupActions()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyTheme(currentTheme: Theme) {
        self.btnSignInWithApple.applyTheme(currentTheme: currentTheme)
    }
    
    private func addingViews() {
        self.addArrangedSubview(self.btnSignInWithApple)
    }
    
    private func updateUI() {
        self.lblError.text = self.errorMessage
        if !self.errorMessage.isEmpty {
            if self.lblError.superview == nil {
                self.addArrangedSubview(self.lblError)
            }
        } else {
            self.removeArrangedSubview(self.lblError)
            self.lblError.removeFromSuperview()
        }
    }
    
    private func setupActions() {
        self.btnSignInWithApple.addTarget(self,
                                          action: #selector(self.btnSignInWithAppleTapped),
                                          for: .touchUpInside)
    }
    
    @objc private func btnSignInWithAppleTapped() {
        self.tapClosure?()
    }
}
