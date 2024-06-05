// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Kingfisher

class HomePageAdvertisementCardView: UIView {
    // MARK: - Properties
    
    private var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.neutralsGray05
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "onboarding_logo_torch")
        return imageView
    }()
    
    private let lblPubTag: UILabel = {
        let label = UILabel()
        label.font = UIFont.sourceSansProFont(.bold, size: 16)
        label.textColor = UIColor.neutralsGray02
        return label
    }()
    
    private let lblTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.sourceSansProFont(.bold, size: 16)
        label.textColor = UIColor.black
        return label
    }()
    
    private let lblContent: UILabel = {
        let label = UILabel()
        label.font = UIFont.sourceSansProFont(.regular, size: 14)
        label.textColor = UIColor.neutralsGray04
        label.numberOfLines = 0
        return label
    }()
    
    private let btnViewMore: BaseTouchableButton = {
        let button = BaseTouchableButton()
        button.setTitle("VIEW MORE", for: .normal)
        button.backgroundColor = UIColor.orangeColor
        button.titleLabel?.font = UIFont.sourceSansProFont(.bold, size: 16)
        button.layer.cornerRadius = 4
        return button
    }()
    
    var didTapAdvertisementClosure: (() -> Void)?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.addSubviews()
        self.addSubviewsConstraints()
        self.btnViewMore.addTarget(self, action: #selector(self.didTapAdvertisement), for: .touchUpInside)
    }
    
    // MARK: - Setup Methods
    
    private func addSubviews() {
        self.addSubview(self.lineView)
        self.addSubview(self.imageView)
        self.addSubview(self.logoImageView)
        self.addSubview(self.lblPubTag)
        self.addSubview(self.lblTitle)
        self.addSubview(self.lblContent)
        self.addSubview(self.btnViewMore)
    }
    
    private func addSubviewsConstraints() {
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.lblPubTag.translatesAutoresizingMaskIntoConstraints = false
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.lblContent.translatesAutoresizingMaskIntoConstraints = false
        self.btnViewMore.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.lineView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.lineView.heightAnchor.constraint(equalToConstant: 1),
            self.lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.imageView.widthAnchor.constraint(equalToConstant: 103),
            self.imageView.heightAnchor.constraint(equalToConstant: 103),
            self.imageView.bottomAnchor.constraint(lessThanOrEqualTo: self.btnViewMore.topAnchor, constant: -16),
            
            self.logoImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.logoImageView.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 16),
            self.logoImageView.widthAnchor.constraint(equalToConstant: 20),
            self.logoImageView.heightAnchor.constraint(equalToConstant: 20),
            
            self.lblPubTag.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.lblPubTag.leadingAnchor.constraint(equalTo: self.logoImageView.trailingAnchor, constant: 6),
            self.lblPubTag.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            self.lblPubTag.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
            
            self.lblTitle.topAnchor.constraint(equalTo: self.lblPubTag.bottomAnchor, constant: 6),
            self.lblTitle.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 16),
            self.lblTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            self.lblContent.topAnchor.constraint(equalTo: self.lblTitle.bottomAnchor, constant: 6),
            self.lblContent.leadingAnchor.constraint(equalTo: self.lblTitle.leadingAnchor, constant: 0),
            self.lblContent.trailingAnchor.constraint(equalTo: self.lblTitle.trailingAnchor, constant: 0),
            self.lblContent.bottomAnchor.constraint(lessThanOrEqualTo: self.btnViewMore.topAnchor, constant: -16),
            
            self.btnViewMore.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.btnViewMore.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            self.btnViewMore.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            self.btnViewMore.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: - Configuration Method
    
    func configureWith(imageUrl: String?, pubTag: String, title: String, content: String) {
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            self.imageView.kf.setImage(with: url)
        }
        
        self.lblPubTag.text = pubTag.uppercased()
        self.lblTitle.text = title
        self.lblContent.text = content
    }
    
    func applyTheme(currentTheme: Theme) {
        switch currentTheme.type {
        case .light:
            self.lineView.backgroundColor = UIColor.neutralsGray05
            self.logoImageView.image = UIImage(named: "onboarding_logo_torch")
            self.lblPubTag.textColor = UIColor.neutralsGray02
            self.lblTitle.textColor = UIColor.neutralsGray01
            self.lblContent.textColor = UIColor.neutralsGray01
        case .dark:
            self.lineView.backgroundColor = UIColor.neutralsGray01
            self.logoImageView.image = UIImage(named: "onboarding_logo_torch")
            self.lblPubTag.textColor = UIColor.neutralsGray02
            self.lblTitle.textColor = UIColor.white
            self.lblContent.textColor = UIColor.neutralsGray04
        }
    }
    
    @objc private func didTapAdvertisement() {
        self.didTapAdvertisementClosure?()
    }
}
