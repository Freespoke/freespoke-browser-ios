// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Common
import Kingfisher

final class HomePageShopsCollectionViewCell: UICollectionViewCell, Themeable {
    static let reuseIdentifier: String = String(describing: type(of: HomePageShopsCollectionViewCell.self))
    
    private let imageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.layer.masksToBounds = true
        return img
    }()
    
    private let imageOverlayView: ShopCollectionViewCellImageOverlayView = {
        let view = ShopCollectionViewCellImageOverlayView()
        return view
    }()
    
    private let lblTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.sourceSansProFont(.semiBold, size: 18)
        label.numberOfLines = 5
        label.lineBreakMode = .byTruncatingTail
        label.textColor = UIColor.white
        return label
    }()
    
    private let overlayActionButton: UIButton = {
        let btn = UIButton()
        return btn
    }()
    
    var themeManager: ThemeManager = AppContainer.shared.resolve()
    var notificationCenter: NotificationProtocol = NotificationCenter.default
    var themeObserver: NSObjectProtocol?
    
    var shop: ShoppingCollectionItemModel?
    
    var shopItemTappedClosure: ((_ url: String) -> Void)?
    
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
        self.shop = nil
        self.imageView.image = nil
        
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
        self.contentView.backgroundColor = UIColor.clear
        
        self.overlayActionButton.addTarget(self, action: #selector(self.overlayActionButtonTapped), for: .touchUpInside)
    }
    
    private func addSubviews() {
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.imageOverlayView)
        
        self.contentView.addSubview(self.lblTitle)
        self.contentView.addSubview(self.overlayActionButton)
    }
    
    private func addSubviewsConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageOverlayView.translatesAutoresizingMaskIntoConstraints = false
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.overlayActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.overlayActionButton.pinToView(view: self.contentView)
        
        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            self.imageOverlayView.topAnchor.constraint(equalTo: self.lblTitle.topAnchor, constant: -5),
            self.imageOverlayView.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            self.imageOverlayView.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor),
            self.imageOverlayView.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor),
            
            self.lblTitle.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            self.lblTitle.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            self.lblTitle.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5)
        ])
    }
    
    // MARK: - Configuration Method
    
    func configure(with shop: ShoppingCollectionItemModel) {
        self.shop = shop
        
        if let imageUrl = shop.thumbnail, let url = URL(string: imageUrl) {
            self.imageView.kf.setImage(with: url)
        }
        
        self.lblTitle.text = shop.title
    }
    
    @objc private func overlayActionButtonTapped() {
        guard let url = self.shop?.url else { return }
        self.shopItemTappedClosure?(url)
    }
    
    func applyTheme() {
        switch self.themeManager.currentTheme.type {
        case .light:
            self.contentView.backgroundColor = UIColor.clear
            self.imageView.backgroundColor = .clear
            self.lblTitle.textColor = UIColor.white
            self.contentView.layer.borderColor = UIColor.neutralsGray05.cgColor
        case .dark:
            self.contentView.backgroundColor = UIColor.clear
            self.imageView.backgroundColor = .clear
            self.lblTitle.textColor = UIColor.white
            self.contentView.layer.borderColor = UIColor.neutralsGray01.cgColor
        }
    }
}
