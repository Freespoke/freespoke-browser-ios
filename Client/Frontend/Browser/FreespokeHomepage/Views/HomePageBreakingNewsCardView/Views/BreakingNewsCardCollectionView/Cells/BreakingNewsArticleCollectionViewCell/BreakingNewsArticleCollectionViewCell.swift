// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Common
import Kingfisher

final class BreakingNewsArticleCollectionViewCell: UICollectionViewCell, Themeable {
    static let reuseIdentifier: String = String(describing: type(of: BreakingNewsArticleCollectionViewCell.self))
    
    private let imageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.layer.masksToBounds = true
        return img
    }()
    
    private var imageOverlayView: BreakingNewsArticleImageOverlayView = {
        let view = BreakingNewsArticleImageOverlayView()
        view.isUserInteractionEnabled = false
        return view
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
    
    var article: BreakingNewsArticleModel?
    
    var articleItemTappedClosure: ((_ url: String) -> Void)?
    
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
        self.article = nil
        
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
        self.contentView.addSubview(self.imageView)
        self.imageView.addSubview(self.imageOverlayView)
        self.contentView.addSubview(self.lineView)
        self.contentView.addSubview(self.bottomView)
        self.contentView.addSubview(self.overlayActionButton)
    }
    
    private func setupConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageOverlayView.translatesAutoresizingMaskIntoConstraints = false
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.overlayActionButton.pinToView(view: self.contentView)
        
        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            self.imageOverlayView.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            self.imageOverlayView.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor),
            self.imageOverlayView.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor),
            
            self.lineView.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 0),
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
        guard let url = self.article?.url else { return }
        self.articleItemTappedClosure?(url)
    }
    
    func applyTheme() {
        self.bottomView.applyTheme(currentTheme: self.themeManager.currentTheme)
        
        switch self.themeManager.currentTheme.type {
        case .light:
            self.imageView.backgroundColor = .clear
            self.lineView.backgroundColor = UIColor.neutralsGray05
            self.contentView.layer.borderColor = UIColor.neutralsGray05.cgColor
        case .dark:
            self.imageView.backgroundColor = .clear
            self.lineView.backgroundColor = UIColor.neutralsGray01
            self.contentView.layer.borderColor = UIColor.neutralsGray01.cgColor
        }
    }
    
    func configure(article: BreakingNewsArticleModel) {
        self.article = article
        if let imageUrl = article.fullInfo.images?.first, let url = URL(string: imageUrl) {
            self.imageView.kf.setImage(with: url)
        }
        
        self.imageOverlayView.configure(with: article)
        
        self.bottomView.configure(with: article.fullInfo.bias, dateConvertedForDisplay: article.fullInfo.datePublishedConverted)
        
        self.applyTheme()
    }
}
