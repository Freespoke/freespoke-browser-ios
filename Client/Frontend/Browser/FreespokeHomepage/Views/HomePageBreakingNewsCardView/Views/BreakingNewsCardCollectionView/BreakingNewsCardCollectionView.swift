// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class BreakingNewsCardCollectionView: UICollectionView {
    var breakingNews: BreakingNewsModel? {
        didSet {
            ensureMainThread(execute: { [weak self] in
                self?.reloadData()
            })
        }
    }
    
    var breakingNewsItemTappedClosure: ((_ url: String) -> Void)?
    
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
        self.register(BreakingNewsArticleCollectionViewCell.self, forCellWithReuseIdentifier: BreakingNewsArticleCollectionViewCell.reuseIdentifier)
        self.register(BreakingNewsTweetCollectionViewCell.self, forCellWithReuseIdentifier: BreakingNewsTweetCollectionViewCell.reuseIdentifier)
    }
}

extension BreakingNewsCardCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.breakingNews?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let breakingNews = self.breakingNews,
              indexPath.row < breakingNews.data.count else { return UICollectionViewCell() }
        
        let cellItem = breakingNews.data[indexPath.row]
        
        switch cellItem.type {
        case .article:
            guard let article = cellItem.article else { return UICollectionViewCell() }
            return self.prepareArticleCell(article: article, collectionView: collectionView, indexPath: indexPath)
        case .tweet:
            guard let tweet = cellItem.tweet else { return UICollectionViewCell() }
            return self.prepareTweetCell(tweet: tweet, collectionView: collectionView, indexPath: indexPath)
        case nil:
            if let article = cellItem.article {
                return self.prepareArticleCell(article: article, collectionView: collectionView, indexPath: indexPath)
            } else if let tweet = cellItem.tweet {
                return self.prepareTweetCell(tweet: tweet, collectionView: collectionView, indexPath: indexPath)
            } else {
                return UICollectionViewCell()
            }
        }
    }
    
    private func prepareArticleCell(article: BreakingNewsArticleModel, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreakingNewsArticleCollectionViewCell.reuseIdentifier, for: indexPath) as? BreakingNewsArticleCollectionViewCell else { return BreakingNewsArticleCollectionViewCell() }
        
        cell.articleItemTappedClosure = { [weak self] url in
            self?.breakingNewsItemTappedClosure?(url)
        }
        
        cell.configure(article: article)
        
        return cell
    }
    
    private func prepareTweetCell(tweet: BreakingNewsTweetModel, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreakingNewsTweetCollectionViewCell.reuseIdentifier, for: indexPath) as? BreakingNewsTweetCollectionViewCell else { return BreakingNewsTweetCollectionViewCell() }
        
        cell.tweetItemTappedClosure = { [weak self] url in
            self?.breakingNewsItemTappedClosure?(url)
        }
        
        cell.configure(tweet: tweet)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 320, height: 220)
    }
}
