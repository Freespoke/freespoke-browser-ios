// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Kingfisher

class BreakingNewsArticleImageOverlayView: UIView {
    // MARK: - Properties
    
    private var topStackView: UIStackView = {
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
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let lblHost: UILabel = {
        let label = UILabel()
        label.font = UIFont.sourceSansProFont(.regular, size: 14)
        label.textColor = UIColor.white
        return label
    }()
    
    private let lblTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.sourceSansProFont(.semiBold, size: 16)
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.textColor = UIColor.white
        return label
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.sublayers?.first?.frame = self.bounds
    }
    
    private func commonInit() {
        self.addSubviews()
        self.addSubviewsConstraints()
        self.setupGradientLayer()
    }
    
    // MARK: - Setup Methods
    
    private func addSubviews() {
        self.addSubview(self.lblTitle)
        self.addSubview(self.topStackView)
    }
    
    private func addSubviewsConstraints() {
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.topStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.topStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            self.topStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            
            self.lblTitle.topAnchor.constraint(equalTo: self.topStackView.bottomAnchor, constant: 8),
            self.lblTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            self.lblTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            self.lblTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            
            self.logoImageView.heightAnchor.constraint(equalToConstant: 24),
            self.logoImageView.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        gradientLayer.locations = [0.0, 0.1, 0.5, 0.75, 1.0]
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Configuration Method
    
    func configure(with article: BreakingNewsArticleModel) {
        self.logoImageView.image = nil
        self.topStackView.arrangedSubviews.forEach({ [weak self] in
            self?.topStackView.removeArrangedSubview($0)
            if $0.superview != nil {
                $0.removeFromSuperview()
            }
            self?.layoutIfNeeded()
        })
        
        if let logoImageUrl = article.fullInfo.publisherIcon, let url = URL(string: logoImageUrl) {
            self.logoImageView.kf.setImage(with: url,
                                           placeholder: nil,
                                           options: [],
                                           completionHandler: { resultImage in
                if case .success = resultImage {
                    self.topStackView.insertArrangedSubview(self.logoImageView, at: 0)
                }
            })
        }
        
        self.lblHost.text = article.fullInfo.publisherName
        self.lblTitle.text = article.fullInfo.headline
        self.topStackView.addArrangedSubview(self.lblHost)
    }
    
    func applyTheme(currentTheme: Theme) {
        switch currentTheme.type {
        case .light:
            self.backgroundColor = UIColor.white
        case .dark:
            self.backgroundColor = UIColor.clear
        }
    }
}
