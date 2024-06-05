// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class HomePageShopsCollectionView: UICollectionView {
    var shoppingCoollection: [ShoppingCoollectionItemModel] = [] {
        didSet {
            ensureMainThread(execute: { [weak self] in
                self?.reloadData()
            })
        }
    }
    
    var shopItemTappedClosure: ((_ url: String) -> Void)?
    
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
        self.register(HomePageShopsCollectionViewCell.self, forCellWithReuseIdentifier: HomePageShopsCollectionViewCell.reuseIdentifier)
    }
}

extension HomePageShopsCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shoppingCoollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < self.shoppingCoollection.count else { return UICollectionViewCell() }
        let shop = self.shoppingCoollection[indexPath.row]
        let cell = self.prepareShopCell(shop: shop, collectionView: collectionView, indexPath: indexPath)
        return cell
    }
    
    private func prepareShopCell(shop: ShoppingCoollectionItemModel, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePageShopsCollectionViewCell.reuseIdentifier, for: indexPath) as? HomePageShopsCollectionViewCell else { return HomePageShopsCollectionViewCell() }
        cell.configure(with: shop)
        cell.shopItemTappedClosure = { [weak self] url in
            self?.shopItemTappedClosure?(url)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 154, height: self.bounds.height)
    }
}
