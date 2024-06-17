// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Combine

protocol SearchPageViewDelegate: AnyObject {
    func prepareJumpBackInContextualHint(view: UILabel)
    func didSelectRowFromSearchPage(indexPath: IndexPath)
}

final class SearchPageView: UIView {
    
    private let maxCountForBookmarks = 5
    
    lazy private var searchCollectionView: UICollectionView = {
        let searchCollectionView = UICollectionView(frame: self.bounds,
                                          collectionViewLayout: createLayout())
        
        HomepageSectionType.cellTypes.forEach {
            searchCollectionView.register($0, forCellWithReuseIdentifier: $0.cellIdentifier)
        }
        searchCollectionView.register(SearchPageHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SearchPageHeaderView.cellIdentifier)
        
        searchCollectionView.keyboardDismissMode = .onDrag
        searchCollectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress)))
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.showsVerticalScrollIndicator = false
        searchCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        searchCollectionView.backgroundColor = .clear
        searchCollectionView.accessibilityIdentifier = a11y.collectionView
        return searchCollectionView
    }()

    // MARK: values
    private var viewModel: HomepageViewModel
    private var freespokeHomepageViewModel: FreespokeHomepageViewModel
    var themeManager: ThemeManager
    private typealias a11y = AccessibilityIdentifiers.FirefoxHomepage
    
    private weak var delegate: SearchPageViewDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: HomepageViewModel, freespokeHomepageViewModel: FreespokeHomepageViewModel, themeManager: ThemeManager, delegate: SearchPageViewDelegate?) {
        self.viewModel = viewModel
        self.themeManager = themeManager
        self.delegate = delegate
        self.freespokeHomepageViewModel = freespokeHomepageViewModel
        super.init(frame: .zero)
        self.subscribeToViewModelStatePublisher()
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareUI() {
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
    }
    
    private func addingViews() {
        self.addSubview(self.searchCollectionView)
    }
    
    private func setupConstraints() {
        self.searchCollectionView.pinToView(view: self)
    }
    
    // MARK: Actions
    @objc fileprivate func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        guard longPressGestureRecognizer.state == .began else { return }
        
        let point = longPressGestureRecognizer.location(in: searchCollectionView)
        guard let indexPath = searchCollectionView.indexPathForItem(at: point),
              let viewModel = viewModel.getSectionViewModel(shownSection: indexPath.section) as? HomepageSectionHandler
        else { return }
        
        viewModel.handleLongPress(with: searchCollectionView, indexPath: indexPath)
    }
    
    func reloadOnRotation(newSize: CGSize) {
        // Force the entire collection view to re-layout
        viewModel.refreshData(for: traitCollection, size: newSize)
        searchCollectionView.reloadData()
        searchCollectionView.collectionViewLayout.invalidateLayout()
        
        // This pushes a reload to the end of the main queue after all the work associated with
        // rotating has been completed. This is important because some of the cells layout are
        // based on the screen state
        DispatchQueue.main.async { [weak self] in
            self?.searchCollectionView.reloadData()
        }
    }
    
    func scrollToTop(animated: Bool = false) {
        searchCollectionView.setContentOffset(.zero, animated: animated)
    }
    
    func updatePocketCellsWithVisibleRatio(_ relativeRect: CGRect? = nil) {
        guard let window = UIWindow.keyWindow else { return }
        let cells = self.searchCollectionView.visibleCells.filter { $0.reuseIdentifier == PocketStandardCell.cellIdentifier }
        var relative = CGRect(
            x: searchCollectionView.frame.minX,
            y: searchCollectionView.frame.minY,
            width: searchCollectionView.frame.width,
            height: searchCollectionView.frame.height + UIWindow.statusBarHeight
        )
        if let rect = relativeRect { relative = rect }
        for cell in cells {
            // For every story cell get it's frame relative to the window
            let targetRect = cell.superview.map { window.convert(cell.frame, from: $0) } ?? .zero
            
            // TODO: If visibility ratio is over 50% sponsored content can be marked as seen by the user
            _ = targetRect.visibilityRatio(relativeTo: relative)
        }
    }
    
    func getOffsetY() -> CGFloat {
        let offset = self.searchCollectionView.contentOffset.y
        return offset
    }
    
    func reloadData() {
        self.searchCollectionView.reloadData()
        self.searchCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func applyTheme() {
        self.searchCollectionView.reloadData()
    }
    
    private func subscribeToViewModelStatePublisher() {
        self.freespokeHomepageViewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                switch self.freespokeHomepageViewModel.state {
                case .loading:
                    break
                case .loaded:
                    guard let news = self.freespokeHomepageViewModel.storyFeed else { return }
                    self.viewModel.updateTrendingNews(trendingNews: news)
                }
            }
            .store(in: &self.cancellables)
    }
    

}

extension SearchPageView {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self]
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self,
                  let viewModel = self.viewModel.getSectionViewModel(shownSection: sectionIndex), viewModel.shouldShow
            else { return nil }
            let width = UIScreen.main.bounds.width
            let height = UIScreen.main.bounds.height
            
            let size = CGSize(width: width, height: height)
            let lay = viewModel.section(for: layoutEnvironment.traitCollection, size: size)
            return lay
        }
        return layout
    }
}

extension SearchPageView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: SearchPageHeaderView.cellIdentifier,
                for: indexPath) as? SearchPageHeaderView/*LabelButtonHeaderView*/,
              let sectionViewModel = viewModel.getSectionViewModel(shownSection: indexPath.section)
        else { return UICollectionReusableView() }
        
        // Configure header only if section is shown
        let headerViewModel = sectionViewModel.headerViewModel
        headerView.setData(dataModel: headerViewModel)
        
        // Jump back in header specific setup
        if sectionViewModel.sectionType == .jumpBackIn {
            self.viewModel.jumpBackInViewModel.sendImpressionTelemetry()
            // Moving called after header view gets configured
            // and delaying to wait for header view layout readjust
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.delegate?.prepareJumpBackInContextualHint(view: headerView.lblTitle)
            }
        }
        headerView.applyTheme(theme: self.themeManager.currentTheme)
        return headerView
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = self.viewModel.shownSections.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.viewModel.getSectionViewModel(shownSection: section)?.numberOfItemsInSection() ?? 0
        if section == 0 {
            if count > self.maxCountForBookmarks {
                return self.maxCountForBookmarks
            } else {
                return count
            }
        } else {
            return count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = self.viewModel.getSectionViewModel(shownSection: indexPath.section) as? HomepageSectionHandler else {
            return UICollectionViewCell()
        }
        return viewModel.configure(collectionView, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.didSelectRowFromSearchPage(indexPath: indexPath)
    }
  
}
