// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class CustomTextField: UITextField {
    // MARK: - Properties
    
    private let iconImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        return imgView
    }()
    
    private var padding: UIEdgeInsets
    
    // MARK: - Initialization
    
    init(padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 4)) {
        self.padding = padding
        super.init(frame: .zero)
        self.setupViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Overrides
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: self.padding.top,
                                             left: self.padding.left + (self.leftView?.bounds.width ?? 0) + 10,
                                             bottom: self.padding.bottom,
                                             right: self.padding.right))
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: self.padding.top,
                                             left: self.padding.left + (self.leftView?.bounds.width ?? 0) + 10,
                                             bottom: self.padding.bottom,
                                             right: self.padding.right))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: self.padding.top,
                                             left: self.padding.left + (self.leftView?.bounds.width ?? 0) + 10,
                                             bottom: self.padding.bottom,
                                             right: self.padding.right))
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: self.padding.left, y: (bounds.height / 2) - (iconImageView.bounds.height / 2), width: 16, height: 16)
    }
    
    override var attributedPlaceholder: NSAttributedString? {
        get {
            let attributes = [
                NSAttributedString.Key.foregroundColor: UIColor.red
            ]
            return NSAttributedString(string: placeholder ?? "", attributes: attributes)
        }
        set {
            super.attributedPlaceholder = newValue
        }
    }
    
    // MARK: - Setup Views
    
    private func setupViews() {
        self.leftView = self.iconImageView
        self.leftViewMode = .always
        
        // Setup Text Field
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 4.0
        self.layer.borderColor = UIColor.whiteColor.cgColor
        self.font = UIFont.sourceSansProFont(.semiBold, size: 22)
    }
    
    func setIcon(_ image: UIImage?) {
        self.iconImageView.image = image
    }
}
