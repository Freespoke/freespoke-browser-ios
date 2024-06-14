// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class HomePageShopsCardView: UIView {
    // MARK: - Properties
    
    private var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.neutralsGray01
        return view
    }()
    
    private var topView: HomePageShopsCardTopView = {
        let view = HomePageShopsCardTopView()
        return view
    }()
    
    private var collectionView: HomePageShopsCollectionView = {
        let cv = HomePageShopsCollectionView(frame: .zero)
        return cv
    }()
    
    private var btnViewAll: UnderlinedButton = {
        let btn = UnderlinedButton()
        btn.setTitle("View All", for: .normal)
        btn.setTitleColor(UIColor.neutralsGray01, for: .normal)
        btn.titleLabel?.font = UIFont.sourceSansProFont(.regular, size: 14)
        return btn
    }()
    
    var btnViewAllDidTapClosure: (() -> Void)?
    var shopItemTappedClosure: ((_ url: String) -> Void)?
    
    // MARK: Initializers
    
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
        
        self.backgroundColor = UIColor.neutralsGray07
        
        self.btnViewAll.addTarget(self, action: #selector(self.didTapViewAllButton), for: .touchUpInside)
        
        self.collectionView.shopItemTappedClosure = { [weak self] url in
            self?.shopItemTappedClosure?(url)
        }
    }
    
    func applyTheme(currentTheme: Theme) {
        self.topView.applyTheme(currentTheme: currentTheme)
        switch currentTheme.type {
        case .light:
            self.lineView.backgroundColor = UIColor.neutralsGray05
            self.backgroundColor = UIColor.white
            self.btnViewAll.setTitleColor(UIColor.neutralsGray01, for: .normal)
        case .dark:
            self.lineView.backgroundColor = UIColor.neutralsGray01
            self.backgroundColor = UIColor.darkBackground
            self.btnViewAll.setTitleColor(UIColor.neutralsGray05, for: .normal)
        }
    }
    
    // MARK: - Configuration
    func configure(with shoppingCollection: [ShoppingCollectionItemModel]) {
        self.collectionView.shoppingCollection = shoppingCollection
    }
}

// MARK: - Add Subviews

extension HomePageShopsCardView {
    private func addSubviews() {
        self.addSubview(self.lineView)
        self.addSubview(self.topView)
        self.addSubview(self.collectionView)
        self.addSubview(self.btnViewAll)
    }
    
    private func addSubviewsConstraints() {
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.btnViewAll.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.lineView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.lineView.heightAnchor.constraint(equalToConstant: 1),
            self.lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.topView.topAnchor.constraint(equalTo: self.lineView.bottomAnchor, constant: 20),
            self.topView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.topView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            self.collectionView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 12),
            self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.collectionView.heightAnchor.constraint(equalToConstant: 188),
            
            self.btnViewAll.topAnchor.constraint(equalTo: self.collectionView.bottomAnchor, constant: 2),
            self.btnViewAll.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            self.btnViewAll.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            self.btnViewAll.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func didTapViewAllButton() {
        self.btnViewAllDidTapClosure?()
    }
}
