// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class SignInWithAppleButton: UIButton {
    private var iconImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.image = UIImage(named: "img_signIn_with_apple_light")
        imgView.isUserInteractionEnabled = false
        return imgView
    }()
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.textColor = UIColor.blackColor
        lbl.font = UIFont.sourceSansProFont(.semiBold, size: 16)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.text = "Sign In with Apple"
        lbl.isUserInteractionEnabled = false
        return lbl
    }()
    
    private var heightConstraint: NSLayoutConstraint!
    
    private let heightDefaultValue: CGFloat = 56
    
    private let activityIndicator = BaseActivityIndicator(activityIndicatorSize: .small)
    
    var height: CGFloat {
        get { return self.heightConstraint.constant }
        set { self.heightConstraint.constant = newValue }
    }
    
    private var text = ""
    
    private var currentTheme: Theme?
    
    init(currentTheme: Theme?) {
        self.currentTheme = currentTheme
        super.init(frame: .zero)
        self.commonInit()
        self.addingViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.whiteColor.cgColor
        self.backgroundColor = self.currentTheme?.type == .dark ? UIColor.black : UIColor.white
        
        self.iconImageView.image = self.currentTheme?.type == .dark ? UIImage(named: "img_signIn_with_apple_dark") : UIImage(named: "img_signIn_with_apple_light")
        self.lblTitle.textColor =  self.currentTheme?.type == .dark ? UIColor.white : UIColor.blackColor
    }
    
    private func addingViews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.lblTitle)
    }
    
    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: self.heightDefaultValue)
        self.heightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            self.iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 16),
            self.iconImageView.widthAnchor.constraint(equalTo: self.iconImageView.heightAnchor, multiplier: 1),
            
            self.lblTitle.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
            self.lblTitle.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor, constant: 0),
            self.lblTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18)
        ])
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
                self?.lblTitle.alpha = 0.5
            }, completion: nil)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: { [weak self] in
                self?.alpha = 1
                self?.titleLabel?.alpha = 1
                self?.lblTitle.alpha = 1
            })
        }
    }
    
    func startIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.text = self.titleLabel?.text ?? ""
            self.setTitle("", for: .normal)
            self.activityIndicator.activityIndicatorColor = self.currentTheme?.type == .dark ? UIColor.white : UIColor.black
            self.activityIndicator.start(pinToView: self)
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
