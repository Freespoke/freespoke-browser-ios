// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Common
import Kingfisher

final class BreakingNewsTweetCollectionViewCell: UICollectionViewCell, Themeable {
    static let reuseIdentifier: String = String(describing: type(of: BreakingNewsTweetCollectionViewCell.self))
    
    private let authorLogoHeighValue: CGFloat = 32
    private let tweetLogoHeighValue: CGFloat = 16
    
    private lazy var authorLogoImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.layer.masksToBounds = true
        img.layer.cornerRadius = self.authorLogoHeighValue / 2
        img.backgroundColor = UIColor.lightGray
        return img
    }()
    
    private var lblsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.layer.masksToBounds = true
        sv.clipsToBounds = false
        return sv
    }()
    
    private let lblAuthorName: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.sourceSansProFont(.semiBold, size: 16)
        lbl.textColor = UIColor.neutralsGray01
        lbl.textAlignment = .left
        lbl.lineBreakMode = .byTruncatingTail
        lbl.numberOfLines = 1
        return lbl
    }()
    
    private let lblAuthorUsername: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.sourceSansProFont(.regular, size: 14)
        lbl.textColor = UIColor.neutralsGray01
        lbl.textAlignment = .left
        lbl.lineBreakMode = .byTruncatingTail
        lbl.numberOfLines = 1
        return lbl
    }()
    
    private lazy var tweetLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius =  self.tweetLogoHeighValue / 2
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: ImageIdentifiers.imgTweetLogo)
        return imageView
    }()
    
    private let lblDescription: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.sourceSansProFont(.regular, size: 14)
        lbl.textColor = UIColor.neutralsGray01
        lbl.textAlignment = .left
        lbl.lineBreakMode = .byTruncatingTail
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.neutralsGray01
        return view
    }()
    
    private let bottomView: BreakingNewsCellBottomView = {
        let view = BreakingNewsCellBottomView()
        return view
    }()
    
    private let overlayActionButton: UIButton = {
        let btn = UIButton()
        return btn
    }()
    
    var themeManager: ThemeManager = AppContainer.shared.resolve()
    var notificationCenter: NotificationProtocol = NotificationCenter.default
    var themeObserver: NSObjectProtocol?
    
    var tweet: BreakingNewsTweetModel?
    
    var tweetItemTappedClosure: ((_ url: String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.tweet = nil
        
        self.applyTheme()
    }
    
    private func prepareUI() {
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 4
        
        self.contentView.layer.borderWidth = 1
        
        self.overlayActionButton.addTarget(self, action: #selector(self.overlayActionButtonTapped), for: .touchUpInside)
        
        self.listenForThemeChange(self)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.applyTheme()
    }
    
    private func addingViews() {
        self.contentView.addSubview(self.authorLogoImageView)
        self.contentView.addSubview(self.lblsStackView)
        self.contentView.addSubview(self.tweetLogoImageView)
        self.contentView.addSubview(self.lblDescription)
        self.contentView.addSubview(self.lineView)
        self.contentView.addSubview(self.bottomView)
        self.contentView.addSubview(self.overlayActionButton)
    }
    
    private func setupConstraints() {
        self.authorLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.lblAuthorName.translatesAutoresizingMaskIntoConstraints = false
        self.lblAuthorUsername.translatesAutoresizingMaskIntoConstraints = false
        self.lblsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.tweetLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.lblDescription.translatesAutoresizingMaskIntoConstraints = false
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.overlayActionButton.pinToView(view: self.contentView)
        
        NSLayoutConstraint.activate([
            self.authorLogoImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
            self.authorLogoImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.authorLogoImageView.heightAnchor.constraint(equalToConstant: self.authorLogoHeighValue),
            self.authorLogoImageView.widthAnchor.constraint(equalToConstant: self.authorLogoHeighValue),
            
            self.lblAuthorName.heightAnchor.constraint(equalToConstant: 22),
            self.lblAuthorUsername.heightAnchor.constraint(equalToConstant: 16),
            
            self.lblsStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
            self.lblsStackView.leadingAnchor.constraint(equalTo: self.authorLogoImageView.trailingAnchor, constant: 12),
            self.lblsStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 35),
            
            self.tweetLogoImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
            self.tweetLogoImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -12),
            self.tweetLogoImageView.heightAnchor.constraint(equalToConstant: self.tweetLogoHeighValue),
            self.tweetLogoImageView.widthAnchor.constraint(equalToConstant: self.tweetLogoHeighValue),
            
            self.lblDescription.topAnchor.constraint(equalTo: self.lblsStackView.bottomAnchor, constant: 12),
            self.lblDescription.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            self.lblDescription.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            
            self.lineView.topAnchor.constraint(equalTo: self.lblDescription.bottomAnchor),
            self.lineView.heightAnchor.constraint(equalToConstant: 1),
            self.lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.bottomView.topAnchor.constraint(equalTo: self.lineView.bottomAnchor, constant: 0),
            self.bottomView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.bottomView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.bottomView.heightAnchor.constraint(equalToConstant: 38),
            self.bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
    
    @objc private func overlayActionButtonTapped() {
        guard let url = self.tweet?.url else { return }
        self.tweetItemTappedClosure?(url)
    }
    
    func applyTheme() {
        self.bottomView.applyTheme(currentTheme: self.themeManager.currentTheme)
        
        switch self.themeManager.currentTheme.type {
        case .light:
            self.backgroundColor = .clear
            self.contentView.backgroundColor = .white
            self.lineView.backgroundColor = UIColor.neutralsGray05
            self.contentView.layer.borderColor = UIColor.neutralsGray05.cgColor
            
            self.lblAuthorName.textColor = UIColor.neutralsGray01
            self.lblAuthorUsername.textColor = UIColor.neutralsGray01
            self.lblDescription.textColor = UIColor.neutralsGray01
        case .dark:
            self.backgroundColor = .clear
            self.contentView.backgroundColor = .darkBackground
            self.lineView.backgroundColor = UIColor.neutralsGray01
            self.contentView.layer.borderColor = UIColor.neutralsGray01.cgColor
            
            self.lblAuthorName.textColor = UIColor.neutralsGray05
            self.lblAuthorUsername.textColor = UIColor.neutralsGray04
            self.lblDescription.textColor = UIColor.white
        }
    }
    
    func configure(tweet: BreakingNewsTweetModel) {
        self.tweet = tweet
        if let imageUrl = tweet.author?.profileImageURL, let url = URL(string: imageUrl) {
            self.authorLogoImageView.kf.setImage(with: url)
        }
        
        self.lblsStackView.arrangedSubviews.forEach({ [weak self] in
            self?.lblsStackView.removeArrangedSubview($0)
            if $0.superview != nil {
                $0.removeFromSuperview()
            }
            self?.layoutIfNeeded()
        })
        
        if let name = tweet.author?.name {
            self.lblAuthorName.text = name
            self.lblsStackView.insertArrangedSubview(self.lblAuthorName, at: 0)
        }
        
        if let username = tweet.author?.username {
            self.lblAuthorUsername.text = username
            self.lblsStackView.addArrangedSubview(self.lblAuthorUsername)
        }
        
        self.lblDescription.text = tweet.text
        
        self.bottomView.configure(with: tweet.bias, dateConvertedForDisplay: tweet.datePublishedConverted)
        
        self.applyTheme()
    }
}
