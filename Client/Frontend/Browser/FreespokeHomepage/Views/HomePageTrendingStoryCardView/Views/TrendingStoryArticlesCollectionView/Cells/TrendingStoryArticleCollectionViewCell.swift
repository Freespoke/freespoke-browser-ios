// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Common
import Kingfisher

final class TrendingStoryArticleCollectionViewCell: UICollectionViewCell, Themeable {
    static let reuseIdentifier: String = String(describing: type(of: TrendingStoryArticleCollectionViewCell.self))
    
    private let imageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.layer.masksToBounds = true
        return img
    }()
    
    private var publisherInfoStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.spacing = 8
        sv.layer.masksToBounds = true
        sv.clipsToBounds = false
        return sv
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let lblPublisherName: UILabel = {
        let label = UILabel()
        label.font = UIFont.sourceSansProFont(.regular, size: 14)
        label.textColor = UIColor.neutralsGray02
        return label
    }()
    
    private let lblArticleHeadline: UILabel = {
        let label = UILabel()
        label.font = UIFont.sourceSansProFont(.semiBold, size: 16)
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.textColor = UIColor.neutralsGray01
        return label
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
    
    var article: StoryFeedArticleModel?
    
    var articleItemTappedClosure: ((_ url: String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.applyTheme()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.article = nil
        self.imageView.image = nil
        self.logoImageView.image = nil
        
        self.applyTheme()
    }
    
    private func commonInit() {
        self.prepareUI()
        
        self.addSubviews()
        self.addSubviewsConstraints()
        self.listenForThemeChange(self)
    }
    
    private func prepareUI() {
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 4
        
        self.contentView.layer.borderWidth = 1
        self.contentView.backgroundColor = UIColor.white
        
        self.overlayActionButton.addTarget(self, action: #selector(self.overlayActionButtonTapped), for: .touchUpInside)
    }
    
    private func addSubviews() {
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.publisherInfoStackView)
        self.contentView.addSubview(self.lblArticleHeadline)
        self.contentView.addSubview(self.lineView)
        self.contentView.addSubview(self.bottomView)
        self.contentView.addSubview(self.overlayActionButton)
    }
    
    private func addSubviewsConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.publisherInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        self.lblArticleHeadline.translatesAutoresizingMaskIntoConstraints = false
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.overlayActionButton.pinToView(view: self.contentView)
        
        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.imageView.heightAnchor.constraint(equalToConstant: 144),
            
            self.logoImageView.heightAnchor.constraint(equalToConstant: 20),
            self.logoImageView.widthAnchor.constraint(equalToConstant: 20),
            
            self.publisherInfoStackView.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 10),
            self.publisherInfoStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            self.publisherInfoStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -8),
            self.publisherInfoStackView.heightAnchor.constraint(equalToConstant: 20),
            
            self.lblArticleHeadline.topAnchor.constraint(equalTo: self.publisherInfoStackView.bottomAnchor, constant: 8),
            self.lblArticleHeadline.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12),
            self.lblArticleHeadline.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
            
            self.lineView.topAnchor.constraint(equalTo: self.lblArticleHeadline.bottomAnchor, constant: 0),
            self.lineView.heightAnchor.constraint(equalToConstant: 1),
            self.lineView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.lineView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            self.bottomView.topAnchor.constraint(equalTo: self.lineView.bottomAnchor, constant: 0),
            self.bottomView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.bottomView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.bottomView.heightAnchor.constraint(equalToConstant: 38),
            self.bottomView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        ])
    }
    
    // MARK: - Configuration Method
    
    func configure(with article: StoryFeedArticleModel) {
        self.article = article
        if let imageUrl = article.images?.first, let url = URL(string: imageUrl) {
            self.imageView.kf.setImage(with: url)
        }
        
        self.publisherInfoStackView.arrangedSubviews.forEach({ [weak self] in
            self?.publisherInfoStackView.removeArrangedSubview($0)
            if $0.superview != nil {
                $0.removeFromSuperview()
            }
            self?.layoutIfNeeded()
        })
        
        if let logoImageUrl = article.publisherIcon, let url = URL(string: logoImageUrl) {
            self.logoImageView.kf.setImage(with: url,
                                           placeholder: nil,
                                           options: [],
                                           completionHandler: { resultImage in
                if case .success(let value) = resultImage {
                    self.publisherInfoStackView.insertArrangedSubview(self.logoImageView, at: 0)
                }
            })
        }
        
        self.lblPublisherName.text = article.publisherName
        self.lblArticleHeadline.text = article.title
        
        self.publisherInfoStackView.addArrangedSubview(self.lblPublisherName)
        
        self.bottomView.configure(with: article.bias, dateConvertedForDisplay: article.datePublishedConverted)
        self.applyTheme()
    }
    
    @objc private func overlayActionButtonTapped() {
        guard let url = self.article?.url else { return }
        self.articleItemTappedClosure?(url)
    }
     
    func applyTheme() {
        self.bottomView.applyTheme(currentTheme: self.themeManager.currentTheme)
        
        switch self.themeManager.currentTheme.type {
        case .light:
            self.contentView.backgroundColor = UIColor.white
            self.imageView.backgroundColor = .clear
            
            self.lblPublisherName.textColor = UIColor.neutralsGray02
            self.lblArticleHeadline.textColor = UIColor.neutralsGray01
            
            self.lineView.backgroundColor = UIColor.neutralsGray05
            self.contentView.layer.borderColor = UIColor.neutralsGray05.cgColor
        case .dark:
            self.contentView.backgroundColor = UIColor.darkBackground
            self.imageView.backgroundColor = .clear
            
            self.lblPublisherName.textColor = UIColor.neutralsGray05
            self.lblArticleHeadline.textColor = UIColor.white
            
            self.lineView.backgroundColor = UIColor.neutralsGray01
            self.contentView.layer.borderColor = UIColor.neutralsGray01.cgColor
        }
    }
}
