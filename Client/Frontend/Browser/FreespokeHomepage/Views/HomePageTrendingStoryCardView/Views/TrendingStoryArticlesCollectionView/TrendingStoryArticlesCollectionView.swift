// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

enum TrendingStoryArticlesCellType {
    case article(article: StoryFeedArticleModel)
    case tweet(tweet: StoryFeedTweetModel)
}

class TrendingStoryArticlesCollectionView: UICollectionView {
    private var cellsArray: [TrendingStoryArticlesCellType] = []
    
    var storyItemTappedClosure: ((_ url: String) -> Void)?
    
    init(frame: CGRect) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        super.init(frame: frame, collectionViewLayout: layout)
        self.prepareCollectionView()
        self.registerCells()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareCollectionView() {
        self.backgroundColor = UIColor.clear
        self.delegate = self
        self.dataSource = self
        self.showsHorizontalScrollIndicator = false
    }
    
    private func registerCells() {
        self.register(TrendingStoryArticleCollectionViewCell.self, forCellWithReuseIdentifier: TrendingStoryArticleCollectionViewCell.reuseIdentifier)
        self.register(TrendingStoryTweetCollectionViewCell.self, forCellWithReuseIdentifier: TrendingStoryTweetCollectionViewCell.reuseIdentifier)
    }
    
    func configure(with storyItem: StoryFeedItemModel) {
        var cells: [TrendingStoryArticlesCellType] = []
        (storyItem.articles ?? []).forEach({ cells.append(.article(article: $0)) })
        (storyItem.tweets ?? []).forEach({ cells.append(.tweet(tweet: $0)) })
        
        self.cellsArray = cells
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1,
                                      execute: { [weak self] in
            self?.reloadData()
        })
    }
}

extension TrendingStoryArticlesCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < self.cellsArray.count else { return UICollectionViewCell() }
        
        let cellType = self.cellsArray[indexPath.row]
        
        switch cellType {
        case .article(let article):
            return self.prepareArticleCell(article: article, collectionView: collectionView, indexPath: indexPath)
        case .tweet(let tweet):
            return self.prepareTweetCell(tweet: tweet, collectionView: collectionView, indexPath: indexPath)
        }
    }
    
    private func prepareArticleCell(article: StoryFeedArticleModel, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingStoryArticleCollectionViewCell.reuseIdentifier, for: indexPath) as? TrendingStoryArticleCollectionViewCell else { return TrendingStoryArticleCollectionViewCell() }
        cell.configure(with: article)
        
        cell.articleItemTappedClosure = { [weak self] url in
            self?.storyItemTappedClosure?(url)
        }
        
        return cell
    }
    
    private func prepareTweetCell(tweet: StoryFeedTweetModel, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingStoryTweetCollectionViewCell.reuseIdentifier, for: indexPath) as? TrendingStoryTweetCollectionViewCell else { return TrendingStoryTweetCollectionViewCell() }
        cell.configure(tweet: tweet)
        cell.tweetItemTappedClosure = { [weak self] url in
            self?.storyItemTappedClosure?(url)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 270, height: 293)
    }
}
