// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class OnboardingBottomButtonsView: UIView {
    
    private var lblDescriptionStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        return sv
    }()
    
    private var btnsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 32
        sv.layer.masksToBounds = true
        sv.clipsToBounds = false
        return sv
    }()
    
    private var widthConstraint: NSLayoutConstraint?
    private var btnsStackViewTopConstraint: NSLayoutConstraint?
    
    deinit {
       NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addingViews()
        self.setupConstraints()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.deviceOrientationDidChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    @objc private func deviceOrientationDidChange() {
//        if UIDevice.current.isPad {
//            if UIDevice.current.orientation.isLandscape {
//                print("TEST: Landscape")
//                let maxSide = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
//                self.widthConstraint?.constant = maxSide * Constants.DrawingSizes.iPadContentWidthFactorPortrait
//                self.layoutIfNeeded()
//            } else {
//                let minSide = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
//                self.widthConstraint?.constant = minSide * Constants.DrawingSizes.iPadContentWidthFactorPortrait
//                self.layoutIfNeeded()
//                print("TEST: Portrait")
//            }
//        }
//    }
    
    @objc private func deviceOrientationDidChange() {
        if UIDevice.current.isPad {
            let minSide = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            self.widthConstraint?.constant = minSide * Constants.DrawingSizes.iPadContentWidthFactorPortrait
            self.layoutIfNeeded()
        }
    }
    
    private func commonInit() {
        self.addingViews()
        self.setupConstraints()
    }
    
    private func addingViews() {
        self.addSubview(self.lblDescriptionStackView)
        self.addSubview(self.btnsStackView)
    }
    
    private func setupConstraints() {
        btnsStackView.translatesAutoresizingMaskIntoConstraints = false
        lblDescriptionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lblDescriptionStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 32),
            lblDescriptionStackView.leadingAnchor.constraint(equalTo: self.btnsStackView.leadingAnchor, constant: 0),
            lblDescriptionStackView.trailingAnchor.constraint(equalTo: self.btnsStackView.trailingAnchor, constant: 0)
        ])
        
        self.btnsStackViewTopConstraint = self.btnsStackView.topAnchor.constraint(equalTo: self.lblDescriptionStackView.bottomAnchor, constant: 32)
        self.btnsStackViewTopConstraint?.isActive = true
        
        // MARK: constraints are set depending on the type of device iPad or iPhone
        if UIDevice.current.isPad {
            let minSide = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            self.widthConstraint = self.btnsStackView.widthAnchor.constraint(equalToConstant: (minSide * Constants.DrawingSizes.iPadContentWidthFactorPortrait))
            self.widthConstraint?.isActive = true
            
            NSLayoutConstraint.activate([
                self.btnsStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                btnsStackView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -32)
            ])
        } else {
            NSLayoutConstraint.activate([
                btnsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
                btnsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
                btnsStackView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -32)
            ])
        }
    }
    
    func makeSureDescriptionLabelRemoved() {
        self.lblDescriptionStackView.arrangedSubviews.forEach({ [weak self] in
            guard let self = self else { return }
            self.lblDescriptionStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        self.btnsStackViewTopConstraint?.constant = 0
    }
    
    func addDescriptionLabel(lblDescription: UITextView) {
        self.lblDescriptionStackView.arrangedSubviews.forEach({ [weak self] in
            guard let self = self else { return }
            self.lblDescriptionStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        
        self.lblDescriptionStackView.addArrangedSubview(lblDescription)
        self.btnsStackViewTopConstraint?.constant = 32
    }
    
    func addViews(views: [UIView]) {
        self.btnsStackView.arrangedSubviews.forEach({ [weak self] in
            guard let self = self else { return }
            self.btnsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        
        views.forEach({ [weak self] in
            self?.btnsStackView.addArrangedSubview($0)
        })
    }
    
    func applyTheme(currentTheme: Theme) {
        switch currentTheme.type {
        case .dark:
            self.backgroundColor = .black
        case .light:
            self.backgroundColor = currentTheme.colors.layer1
        }
    }
    
    func updateButtonsSpacing(to value: CGFloat) {
        self.btnsStackView.spacing = value
    }
}
