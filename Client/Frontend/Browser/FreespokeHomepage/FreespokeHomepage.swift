// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Storage
import Common
import Kingfisher
import Shared
import Combine

protocol FreespokeHomepageDelegate: AnyObject {
    func didPressSearch()
    func didPressMicrophone()
    func didPressBookmarks()
    func didPressRecentlyViewed()
    func didPressShare(_ button: UIButton, url: URL)
    func showURL(url: String)
}

class FreespokeHomepage: UIView {
    // MARK: Properties
    var delegate: FreespokeHomepageDelegate?
    private var viewModel: FreespokeHomepageViewModel
    
    // MARK: Views
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.bounces = false
        return sv
    }()
    
    private var scrollableContentView = UIView()
    
    var avatarView = UIView()
    private var profileIconView = ProfileIconView()
    
    private var topHeaderView = HomepageTopHeaderView()
    private var topSubHeaderView = HomepageTopSubHeaderView()
    private var searchBarView = HomepageSearchBarView()
    private var homePageBackgroundImageView = HomePageBackgroundImageView()
    
    // news feed
    private var newsFeedStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 0
        sv.layer.masksToBounds = true
        sv.clipsToBounds = false
        
        sv.backgroundColor = .neutralsGray07
        return sv
    }()
    private var breakingNewsCardView = HomePageBreakingNewsCardView()
    private var trendingStoryCardView1 = HomePageTrendingStoryCardView()
    private var trendingStoryCardView2 = HomePageTrendingStoryCardView()
    private var trendingStoryCardView3 = HomePageTrendingStoryCardView()
    private var trendingStoryCardView4 = HomePageTrendingStoryCardView()
    private var advertisementCardView = HomePageAdvertisementCardView()
    private var shopsCardView = HomePageShopsCardView()
    private var moreNewsCardView = HomePageMoreNewsCardView()
    
    private var scrollableContentViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: Actions
    var profileIconTapClosure: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Initializers
    init(viewModel: FreespokeHomepageViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.addSubviews()
        self.addSubviewsConstraints()
        
        self.subscribeToViewModelStatePublisher()
        self.subscribeToDeviceOrientationDidChange()
    }
    
    func applyTheme(currentTheme: Theme) {
        self.profileIconView.applyTheme(currentTheme: currentTheme)
        self.topHeaderView.applyTheme(currentTheme: currentTheme)
        self.topSubHeaderView.applyTheme(currentTheme: currentTheme)
        self.searchBarView.applyTheme(currentTheme: currentTheme)
        self.homePageBackgroundImageView.applyTheme(currentTheme: currentTheme)
        self.breakingNewsCardView.applyTheme(currentTheme: currentTheme)
        self.trendingStoryCardView1.applyTheme(currentTheme: currentTheme)
        self.trendingStoryCardView2.applyTheme(currentTheme: currentTheme)
        self.trendingStoryCardView3.applyTheme(currentTheme: currentTheme)
        self.trendingStoryCardView4.applyTheme(currentTheme: currentTheme)
        self.advertisementCardView.applyTheme(currentTheme: currentTheme)
        self.shopsCardView.applyTheme(currentTheme: currentTheme)
        self.moreNewsCardView.applyTheme(currentTheme: currentTheme)
        
        switch currentTheme.type {
        case .light:
            self.backgroundColor = .white
            self.newsFeedStackView.backgroundColor = .neutralsGray07
        case .dark:
            self.backgroundColor = .darkBackground
            self.newsFeedStackView.backgroundColor = .darkBackground
        }
    }
}

// MARK: - Add Subviews

extension FreespokeHomepage {
    private func addSubviews() {
        self.addScrollView()
        self.addProfileIconView()
        self.addTopHeaderView()
        self.addTopSubHeaderView()
        self.addSearchBarView()
        self.addHomePageBackgroundView()
        self.addNewsFeedStackView()
    }
    
    private func addSubviewsConstraints() {
        self.addScrollViewConstraints()
        self.addProfileIconViewConstraints()
        self.addTopHeaderViewConstraints()
        self.addTopSubHeaderViewConstraints()
        self.addSearchBarViewConstraints()
        self.addHomePageBackgroundViewConstraints()
        self.addNewsFeedStackViewConstraints()
    }
}

// MARK: - Profile Icon View

extension FreespokeHomepage {
    private func addScrollView() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.scrollableContentView)
    }
    
    private func addScrollViewConstraints() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.scrollableContentView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.scrollableContentView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.scrollableContentView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.scrollableContentView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.scrollableContentView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
}

// MARK: - Profile Icon View

extension FreespokeHomepage {
    private func addProfileIconView() {
        self.scrollableContentView.addSubview(self.avatarView)
        self.avatarView.addSubview(self.profileIconView)
        
        self.profileIconView.tapClosure = { [weak self] in
            self?.profileIconTapClosure?()
        }
    }
    
    private func addProfileIconViewConstraints() {
        self.avatarView.translatesAutoresizingMaskIntoConstraints = false
        self.profileIconView.translatesAutoresizingMaskIntoConstraints = false
        
        self.profileIconView.pinToView(view: self.avatarView)
        
        NSLayoutConstraint.activate([
            self.avatarView.topAnchor.constraint(equalTo: self.scrollableContentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            self.avatarView.trailingAnchor.constraint(equalTo: self.scrollableContentView.trailingAnchor, constant: -20)
        ])
    }
}

// MARK: - Top Header View

extension FreespokeHomepage {
    private func addTopHeaderView() {
        self.scrollableContentView.addSubview(self.topHeaderView)
    }
    
    private func addTopHeaderViewConstraints() {
        self.topHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topHeaderView.topAnchor.constraint(equalTo: self.avatarView.bottomAnchor, constant: 20),
            self.topHeaderView.leadingAnchor.constraint(greaterThanOrEqualTo: self.scrollableContentView.leadingAnchor, constant: 10),
            self.topHeaderView.trailingAnchor.constraint(lessThanOrEqualTo: self.scrollableContentView.trailingAnchor, constant: -10),
            self.topHeaderView.centerXAnchor.constraint(equalTo: self.scrollableContentView.centerXAnchor)
        ])
    }
}

// MARK: - Top Sub Header View

extension FreespokeHomepage: HomepageTopSubHeaderViewDelegate {
    private func addTopSubHeaderView() {
        self.topSubHeaderView.delegate = self
        self.scrollableContentView.addSubview(self.topSubHeaderView)
    }
    
    private func addTopSubHeaderViewConstraints() {
        self.topSubHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topSubHeaderView.topAnchor.constraint(equalTo: self.topHeaderView.bottomAnchor, constant: 24),
            self.topSubHeaderView.leadingAnchor.constraint(greaterThanOrEqualTo: self.scrollableContentView.leadingAnchor, constant: 10),
            self.topSubHeaderView.trailingAnchor.constraint(lessThanOrEqualTo: self.scrollableContentView.trailingAnchor, constant: -10),
            self.topSubHeaderView.centerXAnchor.constraint(equalTo: self.scrollableContentView.centerXAnchor)
        ])
    }
    
    func didTapLearnMore() {
        self.delegate?.showURL(url: Constants.AppInternalBrowserURLs.aboutFreespokeURL)
    }
}

// MARK: - Search Bar View

extension FreespokeHomepage: HomepageSearchBarViewDelegate {
    private func addSearchBarView() {
        self.searchBarView.delegate = self
        self.scrollableContentView.addSubview(self.searchBarView)
    }
    
    private func addSearchBarViewConstraints() {
        self.searchBarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.searchBarView.topAnchor.constraint(equalTo: self.topSubHeaderView.bottomAnchor, constant: 24),
            self.searchBarView.leadingAnchor.constraint(equalTo: self.scrollableContentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            self.searchBarView.trailingAnchor.constraint(equalTo: self.scrollableContentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            self.searchBarView.centerXAnchor.constraint(equalTo: self.scrollableContentView.centerXAnchor)
        ])
    }
    
    func didTapSearchBar() {
        self.delegate?.didPressSearch()
    }
    
    func didTapMicrophoneButton() {
        self.delegate?.didPressMicrophone()
    }
}

// MARK: - Home Page Background Image View

extension FreespokeHomepage {
    private func addHomePageBackgroundView() {
        self.scrollableContentView.addSubview(self.homePageBackgroundImageView)
    }
    
    private func addHomePageBackgroundViewConstraints() {
        self.homePageBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.homePageBackgroundImageView.topAnchor.constraint(equalTo: self.searchBarView.bottomAnchor, constant: 0),
            self.homePageBackgroundImageView.leadingAnchor.constraint(equalTo: self.scrollableContentView.leadingAnchor),
            self.homePageBackgroundImageView.trailingAnchor.constraint(equalTo: self.scrollableContentView.trailingAnchor),
            self.homePageBackgroundImageView.centerXAnchor.constraint(equalTo: self.scrollableContentView.centerXAnchor)
        ])
    }
}

// MARK: - News Feed Stack View

extension FreespokeHomepage {
    private func addNewsFeedStackView() {
        self.scrollableContentView.addSubview(self.newsFeedStackView)
    }
    
    private func addNewsFeedStackViewConstraints() {
        self.newsFeedStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.scrollableContentViewBottomConstraint = self.newsFeedStackView.bottomAnchor.constraint(equalTo: self.scrollableContentView.bottomAnchor, constant: 0)
        self.scrollableContentViewBottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            self.newsFeedStackView.topAnchor.constraint(equalTo: self.homePageBackgroundImageView.bottomAnchor, constant: 0),
            self.newsFeedStackView.leadingAnchor.constraint(equalTo: self.scrollableContentView.safeAreaLayoutGuide.leadingAnchor),
            self.newsFeedStackView.trailingAnchor.constraint(equalTo: self.scrollableContentView.safeAreaLayoutGuide.trailingAnchor),
            self.newsFeedStackView.centerXAnchor.constraint(equalTo: self.scrollableContentView.centerXAnchor)
        ])
    }
}

// MARK: - View Model

extension FreespokeHomepage {
    // MARK: State
    
    private func subscribeToViewModelStatePublisher() {
        self.viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                switch self.viewModel.state {
                case .loading:
                    self.updateUIForLoadingState()
                case .loaded:
                    self.updateNewsFeed()
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func subscribeToDeviceOrientationDidChange() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.orientationDidChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    @objc func orientationDidChange(_ notification: Notification) {
        let currentOrientation = UIDevice.current.orientation
        switch currentOrientation {
        case .portrait, .portraitUpsideDown:
            self.scrollableContentViewBottomConstraint?.constant = 0
        case .landscapeLeft, .landscapeRight:
            self.scrollableContentViewBottomConstraint?.constant = -24
        default:
            break
        }
    }
}

extension FreespokeHomepage {
    func reloadAllItems() {
        self.viewModel.refetchAllData(completion: nil)
    }
    
    func updateView(decodedJWTToken: FreespokeJWTDecodeModel?) {
        self.profileIconView.updateView(decodedJWTToken: decodedJWTToken)
        self.updateNewsFeed()
    }
    
    private func updateUIForLoadingState() {
        self.newsFeedStackView.arrangedSubviews.forEach({ [weak self] in
            self?.newsFeedStackView.removeArrangedSubview($0)
            if $0.superview != nil {
                $0.removeFromSuperview()
            }
            self?.layoutIfNeeded()
        })
    }
    
    private func updateNewsFeed() {
        self.newsFeedStackView.arrangedSubviews.forEach({ [weak self] in
            self?.newsFeedStackView.removeArrangedSubview($0)
            if $0.superview != nil {
                $0.removeFromSuperview()
            }
            self?.layoutIfNeeded()
        })
        
        self.addBreakingNewsSection()
        self.addTrendingAndWorldStories()
        self.addAdvertisementCardView()
        self.addShopsCardView()
        self.addMoreNewsCardView()
    }
}

// MARK: - Breaking News

extension FreespokeHomepage {
    private func addBreakingNewsSection() {
        guard let breakingNews = self.viewModel.breakingNews else { return }
        
        self.breakingNewsCardView.configure(with: breakingNews)
        
        self.breakingNewsCardView.btnViewAllDidTapClosure = { [weak self] in
            guard let self = self else { return }
            AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                              action: AnalyticsManager.MatomoAction.appHomeBreakingNewsStoryViewAllClick.rawValue,
                                              name: AnalyticsManager.MatomoName.clickName)
            self.delegate?.showURL(url: Constants.AppInternalBrowserURLs.breakingNewsViewAllURL)
        }
        
        self.breakingNewsCardView.breakingNewsItemTappedClosure = { [weak self] url in
            guard let self = self else { return }
            self.delegate?.showURL(url: url)
        }
        
        self.newsFeedStackView.insertArrangedSubview(self.breakingNewsCardView, at: 0)
//        self.newsFeedStackView.addArrangedSubview(self.breakingNewsCardView)
    }
}

// MARK: - Trending and World Stories

extension FreespokeHomepage {
    private func addTrendingAndWorldStories() {
        guard let storyFeed = self.viewModel.storyFeed else { return }
        guard let stories = storyFeed.stories, !stories.isEmpty else { return }
        guard let storyItem1 = stories.first else { return }
        
        self.addTrendingStoryCard1(with: storyItem1)
        
        if stories.count > 1 {
            let storyItem2 = stories[1]
            self.addTrendingStoryCard2(with: storyItem2)
        }
        
        if stories.count > 2 {
            let storyItem3 = stories[2]
            self.addTrendingStoryCard3(with: storyItem3)
        }
        
        if stories.count > 3 {
            let storyItem4 = stories[3]
            self.addTrendingStoryCard4(with: storyItem4)
        }
    }
    
    private func addTrendingStoryCard1(with storyItem: StoryFeedItemModel) {
        self.trendingStoryCardView1.didTapShareButtonCompletion = { [weak self] button, url in
            self?.delegate?.didPressShare(button, url: url)
        }
        
        self.trendingStoryCardView1.storyItemTappedClosure = { [weak self] url in
            self?.delegate?.showURL(url: url)
        }
        
        self.trendingStoryCardView1.didTapSeeMoreButtonCompletion = { [weak self] url in
            self?.delegate?.showURL(url: url)
        }
        
        self.trendingStoryCardView1.didTapHeadlineActionButtonCompletion = { [weak self] url in
            self?.delegate?.showURL(url: url)
        }
        
        self.trendingStoryCardView1.configure(with: storyItem)
        
        self.newsFeedStackView.addArrangedSubview(self.trendingStoryCardView1)
    }
    
    private func addTrendingStoryCard2(with storyItem: StoryFeedItemModel) {
        self.trendingStoryCardView2.didTapShareButtonCompletion = { [weak self] button, url in
            self?.delegate?.didPressShare(button, url: url)
        }
        
        self.trendingStoryCardView2.storyItemTappedClosure = { [weak self] url in
            self?.delegate?.showURL(url: url)
        }
        
        self.trendingStoryCardView2.didTapSeeMoreButtonCompletion = { [weak self] url in
            self?.delegate?.showURL(url: url)
        }
        
        self.trendingStoryCardView2.didTapHeadlineActionButtonCompletion = { [weak self] url in
            self?.delegate?.showURL(url: url)
        }
        
        self.trendingStoryCardView2.configure(with: storyItem)
        
        self.newsFeedStackView.addArrangedSubview(self.trendingStoryCardView2)
    }
    
    private func addTrendingStoryCard3(with storyItem: StoryFeedItemModel) {
        self.trendingStoryCardView3.didTapShareButtonCompletion = { [weak self] button, url in
            self?.delegate?.didPressShare(button, url: url)
        }
        
        self.trendingStoryCardView3.storyItemTappedClosure = { [weak self] url in
            self?.delegate?.showURL(url: url)
        }
        
        self.trendingStoryCardView3.didTapSeeMoreButtonCompletion = { [weak self] url in
            self?.delegate?.showURL(url: url)
        }
        
        self.trendingStoryCardView3.didTapHeadlineActionButtonCompletion = { [weak self] url in
            self?.delegate?.showURL(url: url)
        }
        
        self.trendingStoryCardView3.configure(with: storyItem)
        
        self.newsFeedStackView.addArrangedSubview(self.trendingStoryCardView3)
    }
    
    private func addTrendingStoryCard4(with storyItem: StoryFeedItemModel) {
        self.trendingStoryCardView4.didTapShareButtonCompletion = { [weak self] button, url in
            self?.delegate?.didPressShare(button, url: url)
        }
        
        self.trendingStoryCardView4.storyItemTappedClosure = { [weak self] url in
            self?.delegate?.showURL(url: url)
        }
        
        self.trendingStoryCardView4.didTapSeeMoreButtonCompletion = { [weak self] url in
            self?.delegate?.showURL(url: url)
        }
        
        self.trendingStoryCardView4.didTapHeadlineActionButtonCompletion = { [weak self] url in
            self?.delegate?.showURL(url: url)
        }
        
        self.trendingStoryCardView4.configure(with: storyItem)
        
        self.newsFeedStackView.addArrangedSubview(self.trendingStoryCardView4)
    }
}

// MARK: - Advertisement Card View

extension FreespokeHomepage {
    private func addAdvertisementCardView() {
        guard let advertisement = self.viewModel.advertisement else { return }
        
        AppSessionManager.shared.checkIsUserHasPremium(isPremiumCompletion: { isPremium in
            guard !isPremium else { return }
            ensureMainThread { [weak self] in
                guard let self = self else { return }
                
                // setup advertisementCardView
                self.advertisementCardView.configureWith(imageUrl: advertisement.data?.image,
                                                         pubTag: advertisement.data?.pubTag ?? "SPONSORED",
                                                         title: advertisement.data?.title ?? "",
                                                         content: advertisement.data?.content ?? "")
                self.advertisementCardView.didTapAdvertisementClosure = { [weak self] in
                    guard let self = self else { return }
                    if let advertisementUrl = advertisement.data?.url {
                        self.delegate?.showURL(url: advertisementUrl)
                    }
                }
                
                // add advertisementCardView
                if let storyFeed = self.viewModel.storyFeed,
                   let stories = storyFeed.stories,
                   !stories.isEmpty {
                    self.newsFeedStackView.insertArrangedSubview(self.advertisementCardView, at: 1)
                } else {
                    if !self.newsFeedStackView.arrangedSubviews.isEmpty {
                        self.newsFeedStackView.insertArrangedSubview(self.advertisementCardView, at: 1)
                    } else {
                        self.newsFeedStackView.addArrangedSubview(self.advertisementCardView)
                    }
                }
            }
        })
    }
}

// MARK: - Shops Card View

extension FreespokeHomepage {
    private func addShopsCardView() {
        guard let shoppingCollection = self.viewModel.shoppingCollection, !shoppingCollection.collections.isEmpty else { return }
        
        self.shopsCardView.configure(with: shoppingCollection.collections)
        
        self.shopsCardView.btnViewAllDidTapClosure = { [weak self] in
            guard let self = self else { return }
            
            AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                              action: AnalyticsManager.MatomoAction.appHomeShopUsaViewMoreClick.rawValue,
                                              name: AnalyticsManager.MatomoName.clickName)
            
            self.delegate?.showURL(url: Constants.AppInternalBrowserURLs.viewMoreShopsURL)
        }
        
        self.shopsCardView.shopItemTappedClosure = { [weak self] url in
            guard let self = self else { return }
            self.delegate?.showURL(url: url)
        }
        
        let subviewsCount = self.newsFeedStackView.arrangedSubviews.count
        
        if subviewsCount > 0 {
            self.newsFeedStackView.insertArrangedSubview(self.shopsCardView, at: subviewsCount - 1)
        } else {
            self.newsFeedStackView.addArrangedSubview(self.shopsCardView)
        }
    }
}

// MARK: - More News Card View

extension FreespokeHomepage {
    private func addMoreNewsCardView() {
        self.moreNewsCardView.didTapMoreNewsButtonClosure = { [weak self] in
            self?.delegate?.showURL(url: Constants.AppInternalBrowserURLs.newsURL)
        }
        
        self.newsFeedStackView.addArrangedSubview(self.moreNewsCardView)
    }
}
