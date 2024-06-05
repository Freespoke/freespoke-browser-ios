// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class HomePageBreakingNewsCardView: UIView {
    // MARK: - Properties
    
    private var topView: BreakingNewsCardTopView = {
        let view = BreakingNewsCardTopView()
        return view
    }()
    
    private var collectionView: BreakingNewsCardCollectionView = {
        let cv = BreakingNewsCardCollectionView(frame: .zero)
        return cv
    }()
    
    var btnViewAllDidTapClosure: (() -> Void)?
    
    var breakingNewsItemTappedClosure: ((_ url: String) -> Void)?
    
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
        
        self.topView.btnViewAllDidTapClosure = { [weak self] in
            self?.btnViewAllDidTapClosure?()
        }
        
        self.collectionView.breakingNewsItemTappedClosure = { [weak self] url in
            self?.breakingNewsItemTappedClosure?(url)
        }
    }
    
    func applyTheme(currentTheme: Theme) {
        self.topView.applyTheme(currentTheme: currentTheme)
        switch currentTheme.type {
        case .light:
            self.backgroundColor = UIColor.neutralsGray07
        case .dark:
            self.backgroundColor = UIColor.darkBackground
        }
    }
    
    // MARK: - Configuration
    func configure(with breakingNews: BreakingNewsModel) {
        self.collectionView.breakingNews = breakingNews
    }
}

// MARK: - Add Subviews

extension HomePageBreakingNewsCardView {
    private func addSubviews() {
        self.addSubview(self.topView)
        self.addSubview(self.collectionView)
    }
    
    private func addSubviewsConstraints() {
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.topView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.collectionView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 20),
            self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            self.collectionView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
}
