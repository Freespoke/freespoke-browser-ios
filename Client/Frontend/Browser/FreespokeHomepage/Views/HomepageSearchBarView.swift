// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

protocol HomepageSearchBarViewDelegate: AnyObject {
    func didTapSearchBar()
    func didTapMicrophoneButton()
}

class HomepageSearchBarView: UIView {
    // MARK: - Properties
    
    weak var delegate: HomepageSearchBarViewDelegate?
    
    private lazy var imgSearchView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.image = UIImage(named: "img_home_search_icon")
        img.layer.masksToBounds = true
        return img
    }()
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.sourceSansProFont(.regular, size: 17)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Search anything privately..."
        return lbl
    }()
    
    private lazy var imgMicroView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.image = UIImage(named: "img_home_microphone_icon")
        img.layer.masksToBounds = true
        img.isHidden = true
        return img
    }()
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.setupUI()
        self.addSubviews()
        self.addSubviewsConstraints()
        
        // Add the tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        self.isUserInteractionEnabled = true
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 12
    }
    
    func applyTheme(currentTheme: Theme) {
        switch currentTheme.type {
        case .light:
            self.backgroundColor = UIColor.neutralsGray07
            self.layer.borderColor = UIColor.neutralsGray5.cgColor
            self.lblTitle.textColor = UIColor.onboardingTitleDark
            self.imgSearchView.image = UIImage(named: "img_home_search_icon")?.withTintColor(UIColor.neutralsGray01,
                                                                                             renderingMode: .alwaysOriginal)
            self.imgMicroView.image = UIImage(named: "img_home_microphone_icon")?.withTintColor(UIColor.neutralsGray01,
                                                                                                renderingMode: .alwaysOriginal)
        case .dark:
            self.backgroundColor = UIColor.whiteColor.withAlphaComponent(0.05)
            self.layer.borderColor = UIColor.neutralsGray01.cgColor
            self.lblTitle.textColor = UIColor.gray7
            self.imgSearchView.image = UIImage(named: "img_home_search_icon")?.withTintColor(UIColor.white,
                                                                                             renderingMode: .alwaysOriginal)
            self.imgMicroView.image = UIImage(named: "img_home_microphone_icon")?.withTintColor(UIColor.white,
                                                                                                renderingMode: .alwaysOriginal)
        }
    }
}

// MARK: - Add Subviews

extension HomepageSearchBarView {
    
    private func addSubviews() {
        self.addSubview(self.imgSearchView)
        self.addSubview(self.lblTitle)
        self.addSubview(self.imgMicroView)
    }
    
    private func addSubviewsConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.imgSearchView.translatesAutoresizingMaskIntoConstraints = false
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.imgMicroView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.imgSearchView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.imgSearchView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.imgSearchView.heightAnchor.constraint(equalToConstant: 20),
            self.imgSearchView.widthAnchor.constraint(equalToConstant: 20),
            
            self.lblTitle.leadingAnchor.constraint(equalTo: self.imgSearchView.trailingAnchor, constant: 10),
            self.lblTitle.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            self.imgMicroView.leadingAnchor.constraint(equalTo: self.lblTitle.trailingAnchor, constant: 10),
            self.imgMicroView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            self.imgMicroView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.imgMicroView.heightAnchor.constraint(equalToConstant: 30),
            self.imgMicroView.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        // remove line below below when the imgMicroView will be unhidden
        self.delegate?.didTapSearchBar()
        
        // uncommit lines below when the imgMicroView will be unhidden
        /*
        let location = gesture.location(in: self)
        
        if self.imgMicroView.frame.contains(location) {
            self.delegate?.didTapMicrophoneButton()
        } else {
            self.delegate?.didTapSearchBar()
        }
         */
    }
}
