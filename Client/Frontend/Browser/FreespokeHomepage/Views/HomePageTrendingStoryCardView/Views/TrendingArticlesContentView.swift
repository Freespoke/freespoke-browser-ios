// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class TrendingArticlesContentView: UIView {
    // MARK: - Properties
    
    private var collectionView: TrendingStoryArticlesCollectionView = {
        let cv = TrendingStoryArticlesCollectionView(frame: .zero)
        return cv
    }()
    
    var storyItemTappedClosure: ((_ url: String) -> Void)?
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.prepareCollectionView()
        
        self.addSubviews()
        self.addSubviewsConstraints()
        
        self.backgroundColor = .clear
    }
    
    func applyTheme(currentTheme: Theme) {
        
    }
    
    private func prepareCollectionView() {
        self.collectionView.storyItemTappedClosure = { [weak self] url in
            self?.storyItemTappedClosure?(url)
        }
    }
    
    func configure(with storyItem: StoryFeedItemModel) {
        self.collectionView.configure(with: storyItem)
    }
}

// MARK: - Add Subviews

extension TrendingArticlesContentView {
    private func addSubviews() {
        self.addSubview(self.collectionView)
    }
    
    private func addSubviewsConstraints() {
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            self.collectionView.heightAnchor.constraint(equalToConstant: 293)
        ])
    }
}
