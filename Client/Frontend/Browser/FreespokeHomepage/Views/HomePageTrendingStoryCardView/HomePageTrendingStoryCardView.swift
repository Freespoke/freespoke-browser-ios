// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class HomePageTrendingStoryCardView: UIView {
    // MARK: - Properties
    
    private var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.neutralsGray01
        return view
    }()
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textColor = UIColor.neutralsGray02
        lbl.font = UIFont.sourceSansProFont(.bold, size: 16)
        lbl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return lbl
    }()
    
    private var btnShare: ShareButtonWithTitle = {
        let btn = ShareButtonWithTitle()
        btn.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        btn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return btn
    }()
    
    private var lblSubTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textColor = UIColor.neutralsGray01
        lbl.font = UIFont.sourceSansProFont(.semiBold, size: 18)
        return lbl
    }()
    
    private var lblUpdatedDate: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textColor = UIColor.neutralsGray02
        lbl.font = UIFont.sourceSansProFont(.regular, size: 14)
        return lbl
    }()
    
    private var btnHeadlineAction: UIButton = {
        let btn = UIButton()
        return btn
    }()
    
    private var buttonsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        return sv
    }()
    
    private var trendingStoryBtnsView: TrendingStoryBtnsView?
    
    private var middleLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.neutralsGray05
        return view
    }()
    
    private var contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.backgroundColor = .neutralsGray07
        return sv
    }()
    
    private var articlesContentView: TrendingArticlesContentView = {
        let view = TrendingArticlesContentView()
        return view
    }()
    
    private var summaryView: TrendingStorySummaryView = {
        let view = TrendingStorySummaryView()
        return view
    }()
    
    
    private var storyItem: StoryFeedItemModel?
    
    var didTapShareButtonCompletion: ((_ button: UIButton, _ url: URL) -> Void)?
    var didTapHeadlineActionButtonCompletion: ((_ url: String) -> Void)?
    var didTapSeeMoreButtonCompletion: ((_ url: String) -> Void)?
    var storyItemTappedClosure: ((_ url: String) -> Void)?
    var summaryViewLinkTappedClosure: ((_ url: String) -> Void)?
    
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
        
        self.btnHeadlineAction.addTarget(self, action: #selector(self.didTapHeadlineActionButton(_:)), for: .touchUpInside)
        self.btnShare.addTarget(self, action: #selector(self.didTapShareButton(_:)), for: .touchUpInside)
        
        self.articlesContentView.storyItemTappedClosure = { [weak self] url in
            
            switch self?.storyItem?.category {
            case .trending:
                AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                                  action: AnalyticsManager.MatomoAction.appHomeTrendingStoryTabArticlesTabContentClick.rawValue,
                                                  name: AnalyticsManager.MatomoName.clickName)
            case .world:
                AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                                  action: AnalyticsManager.MatomoAction.appHomeWorldStoryContentClick.rawValue,
                                                  name: AnalyticsManager.MatomoName.clickName)
            case nil:
                break
            }
            
            self?.storyItemTappedClosure?(url)
        }
        
        self.summaryView.linkTappedClosure = { [weak self] url in
            self?.summaryViewLinkTappedClosure?(url)
        }
    }
    
    func applyTheme(currentTheme: Theme) {
        self.summaryView.applyTheme(currentTheme: currentTheme)
        
        switch currentTheme.type {
        case .light:
            self.contentStackView.backgroundColor = .neutralsGray07
            self.lineView.backgroundColor = UIColor.neutralsGray05
            self.lblTitle.textColor = UIColor.neutralsGray02
            self.lblSubTitle.textColor = UIColor.neutralsGray01
            self.lblUpdatedDate.textColor = UIColor.neutralsGray02
            self.middleLineView.backgroundColor = UIColor.neutralsGray05
        case .dark:
            self.contentStackView.backgroundColor = .darkBackground
            self.lineView.backgroundColor = UIColor.neutralsGray01
            self.lblTitle.textColor = UIColor.neutralsGray05
            self.lblSubTitle.textColor = UIColor.white
            self.lblUpdatedDate.textColor = UIColor.neutralsGray05
            self.middleLineView.backgroundColor = UIColor.neutralsGray01
        }
    }
    
    // MARK: - Configuration
    func configure(with storyItem: StoryFeedItemModel) {
        self.storyItem = storyItem
        
        self.lblTitle.text = storyItem.category?.title ?? StoryCategoryType.trending.title
        self.lblSubTitle.text = storyItem.name
        if let updatedAtConverted = storyItem.updatedAtConverted {
            self.lblUpdatedDate.text = "Updated: \(updatedAtConverted)"
        }
        
        self.setupButtonsView()
        self.articlesContentView.configure(with: storyItem)
    }
    
    private func setupButtonsView() {
        self.buttonsStackView.arrangedSubviews.forEach({ [weak self] in
            guard let self = self else { return }
            self.buttonsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        
        var segmentControlTabs: [TrendingStorySegmentControlTabs] = []
        let storyHasSeeMore = self.storyItem?.hasSeeMore ?? false
        
        if let hasAiSummary = self.storyItem?.hasAiSummary, hasAiSummary {
            segmentControlTabs = [.articlesBtn, .storySummaryBtn]
        } else if storyHasSeeMore {
            segmentControlTabs = [.articlesBtn]
        }
        
        self.trendingStoryBtnsView = TrendingStoryBtnsView(segmentControlTabs: segmentControlTabs,
                                                           hasSeeMoreButton: storyHasSeeMore)
        
        self.trendingStoryBtnsView?.delegate = self
        
        if let trendingStoryBtnsView = self.trendingStoryBtnsView {
            self.buttonsStackView.addArrangedSubview(trendingStoryBtnsView)
        }
    }
}

// MARK: - Add Subviews

extension HomePageTrendingStoryCardView {
    private func addSubviews() {
        self.addSubview(self.lineView)
        self.addSubview(self.lblTitle)
        
        self.addSubview(self.lblSubTitle)
        self.addSubview(self.lblUpdatedDate)
        self.addSubview(self.btnHeadlineAction)
        
        self.addSubview(self.btnShare)
        
        self.addSubview(self.buttonsStackView)
        self.addSubview(self.middleLineView)
        self.addSubview(self.contentStackView)
    }
    
    private func addSubviewsConstraints() {
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.btnShare.translatesAutoresizingMaskIntoConstraints = false
        self.lblSubTitle.translatesAutoresizingMaskIntoConstraints = false
        self.lblUpdatedDate.translatesAutoresizingMaskIntoConstraints = false
        self.btnHeadlineAction.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.middleLineView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.lineView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.lineView.heightAnchor.constraint(equalToConstant: 1),
            self.lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.lblTitle.topAnchor.constraint(equalTo: self.lineView.bottomAnchor, constant: 20),
            self.lblTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            self.btnShare.centerYAnchor.constraint(equalTo: self.lblTitle.centerYAnchor, constant: 0),
            self.btnShare.leadingAnchor.constraint(greaterThanOrEqualTo: self.lblTitle.trailingAnchor, constant: 10),
            self.btnShare.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.btnShare.heightAnchor.constraint(equalToConstant: 30),
            self.btnShare.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            self.lblSubTitle.topAnchor.constraint(equalTo: self.lblTitle.bottomAnchor, constant: 8),
            self.lblSubTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.lblSubTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            self.btnHeadlineAction.topAnchor.constraint(equalTo: self.lblSubTitle.topAnchor, constant: 0),
            self.btnHeadlineAction.leadingAnchor.constraint(equalTo: self.lblSubTitle.leadingAnchor, constant: 0),
            self.btnHeadlineAction.trailingAnchor.constraint(equalTo: self.lblSubTitle.trailingAnchor, constant: 0),
            self.btnHeadlineAction.bottomAnchor.constraint(equalTo: self.lblUpdatedDate.bottomAnchor, constant: 0),
            
            self.lblUpdatedDate.topAnchor.constraint(equalTo: self.lblSubTitle.bottomAnchor, constant: 8),
            self.lblUpdatedDate.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.lblUpdatedDate.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            self.buttonsStackView.topAnchor.constraint(equalTo: self.lblUpdatedDate.bottomAnchor, constant: 12),
            self.buttonsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.buttonsStackView.bottomAnchor.constraint(equalTo: self.middleLineView.topAnchor, constant: 0),
            
            self.middleLineView.heightAnchor.constraint(equalToConstant: 1),
            self.middleLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.middleLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.contentStackView.topAnchor.constraint(equalTo: self.middleLineView.bottomAnchor),
            self.contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
    
    @objc private func didTapShareButton(_ sender: UIButton) {
        guard let storyItem = self.storyItem else { return }
        guard let shareLinkString = storyItem.links?.shareLink else { return }
        guard let shareLink = URL(string: shareLinkString) else { return }
        
        AnalyticsManager.trackMatomoEvent(category: .appShareCategory,
                                          action: AnalyticsManager.MatomoAction.appShareStoryFromHomeAction.rawValue,
                                          name: AnalyticsManager.MatomoName.clickName)
        
        self.didTapShareButtonCompletion?(sender, shareLink)
    }
    
    @objc private func didTapHeadlineActionButton(_ sender: UIButton) {
        guard let storyItem = self.storyItem else { return }
        guard let shareLinkString = storyItem.links?.shareLink else { return }
        self.didTapHeadlineActionButtonCompletion?(shareLinkString)
    }
    
    private func showArticles() {
        self.contentStackView.addArrangedSubview(self.articlesContentView)
    }
    
    private func showStorySummary() {
        /* test data
         let sources = ["Sky News", "Variety", "The Sun"]
         
         let summaryText = """
         <p>U.K. Prime Minister <a href=\"https://freespoke.com/search/web?q=Rishi%20Sunak\">Rishi Sunak</a> has announced a general election to be held on July 4, following a period of intense speculation and political maneuvering. Reports from various sources, including <a href=\"https://freespoke.com/search/web?q=Sky%20News\">Sky News</a>, Variety, and The Sun, indicate that this decision was made after comprehensive discussions within <a href=\"https://freespoke.com/search/web?q=Downing%20Street\">Downing Street</a>. Sunak’s decision came unexpectedly, as he had not completed the key pledges he set out in January 2023, such as curbing the influx of small boats across the Channel. Despite rumors and a day filled with high drama and emergency meetings, Sunak has chosen to challenge Labour’s <a href=\"https://freespoke.com/search/web?q=Keir%20Starmer\">Keir Starmer</a> at the height of summer, a strategic move likely influenced by recent improvements in inflation rates and economic forecasts.</p><p>In a speech delivered in the pouring rain on the steps of <a href=\"https://freespoke.com/search/web?q=10%20Downing%20Street\">10 Downing Street</a>, Sunak highlighted his record during the pandemic and reassured the public of his commitment to their welfare. The election will decide 650 seats in the <a href=\"https://freespoke.com/search/web?q=House%20of%20Commons\">House of Commons</a>, with the <a href=\"https://freespoke.com/search/web?q=Labour%20Party\">Labour Party</a> currently leading the polls. Recent local council election results show Labour gaining ground, while the Conservatives have faced a decline. The election will not only determine the ruling party but may also result in a hung parliament, where smaller parties like the <a href=\"https://freespoke.com/search/web?q=Liberal%20Democrats\">Liberal Democrats</a> and <a href=\"https://freespoke.com/search/web?q=Scottish%20National%20Party\">Scottish National Party</a> could play decisive roles.</p><p>Sunak’s tenure as Prime Minister began in October 2022 following a turbulent period marked by the resignations of <a href=\"https://freespoke.com/search/web?q=Liz%20Truss\">Liz Truss</a> and <a href=\"https://freespoke.com/search/web?q=Boris%20Johnson\">Boris Johnson</a>. Despite internal party challenges and political scandals, the Conservative government has implemented supportive measures for the creative sector, such as corporate tax relief for film and TV studios. However, Sunak's government has faced criticism for a decade of austerity that affected arts funding and the music industry's touring capabilities in a post-Brexit landscape. As the election day approaches, Sunak has emphasized positive economic indicators, such as reduced inflation rates and favorable IMF growth forecasts, to bolster his campaign.</p>
         """
         */
        
        guard let summaryText = self.storyItem?.aiSummary?.htmlLinkified else { return }
        self.summaryView.configure(with: summaryText)
        self.contentStackView.addArrangedSubview(self.summaryView)
    }
}

extension HomePageTrendingStoryCardView: TrendingStoryBtnsViewDelegate {
    func seeMoreTapped() {
        guard let storyItem = self.storyItem else { return }
        guard let seeMoreLinkString = storyItem.links?.seeMoreLink else { return }
        
        AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                          action: AnalyticsManager.MatomoAction.appHomeTrendingStoryTabClickStorySeeMore.rawValue,
                                          name: AnalyticsManager.MatomoName.clickName)
        
        self.didTapSeeMoreButtonCompletion?(seeMoreLinkString)
    }
    
    func articlesTabDidSelect() {
        self.contentStackView.arrangedSubviews.forEach({ [weak self] in
            guard let self = self else { return }
            self.contentStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        self.showArticles()
    }
    
    func storySummaryTabDidSelect() {
        self.contentStackView.arrangedSubviews.forEach({ [weak self] in
            guard let self = self else { return }
            self.contentStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        self.showStorySummary()
    }
}
