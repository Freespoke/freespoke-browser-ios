// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Common

protocol TrendingStoryBtnsViewDelegate: AnyObject {
    func seeMoreTapped()
    func articlesTabDidSelect()
    func storySummaryTabDidSelect()
}

class TrendingStoryBtnsView: UIView, Themeable {
    // MARK: - Properties
    
    weak var delegate: TrendingStoryBtnsViewDelegate?
    
    private var tabsView: TrendingStorySegmentedControlView?
    private var seeMoreButton: UIButton?
    
    var themeManager: ThemeManager = AppContainer.shared.resolve()
    var notificationCenter: NotificationProtocol = NotificationCenter.default
    var themeObserver: NSObjectProtocol?
    
    // MARK: - Initializers
    init(segmentControlTabs: [TrendingStorySegmentControlTabs], hasSeeMoreButton: Bool) {
        super.init(frame: .zero)
        self.commonInit(segmentControlTabs: segmentControlTabs, hasSeeMoreButton: hasSeeMoreButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.applyTheme()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure tabsView and seeMoreButton are present
        guard let tabsView = self.tabsView, let seeMoreButton = self.seeMoreButton else { return }
        
        // Calculate width of each tab item
        let tabCount = CGFloat(tabsView.tabs.count)
        let tabItemWidth = tabsView.bounds.width / tabCount
        
        // Get current width of seeMoreButton
        let currentSeeMoreButtonWidth = seeMoreButton.bounds.width
        
        // Update width constraint for seeMoreButton if the new width is greater than the current width
        if tabItemWidth > currentSeeMoreButtonWidth {
            for constraint in seeMoreButton.constraints {
                if constraint.firstAttribute == .width {
                    constraint.constant = tabItemWidth
                    return
                }
            }
            
            // Add width constraint if not present
            seeMoreButton.widthAnchor.constraint(equalToConstant: tabItemWidth).isActive = true
        } else if tabCount == 1 {
            seeMoreButton.widthAnchor.constraint(equalToConstant: currentSeeMoreButtonWidth + 20).isActive = true
            tabsView.widthAnchor.constraint(equalToConstant: currentSeeMoreButtonWidth).isActive = true
        }
    }
    
    private func commonInit(segmentControlTabs: [TrendingStorySegmentControlTabs], hasSeeMoreButton: Bool) {
        if !segmentControlTabs.isEmpty {
            self.tabsView = TrendingStorySegmentedControlView(tabs: segmentControlTabs)
            self.tabsView?.delegate = self
        }
        
        if hasSeeMoreButton {
            self.setupSeeMoreButton()
        }
        
        self.addingSubviews()
        
        self.listenForThemeChange(self)
        self.applyTheme()
    }
    
    private func setupSeeMoreButton() {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.sourceSansProFont(.semiBold, size: 16)
        btn.setTitle("See More", for: .normal)
        btn.addTarget(self, action: #selector(self.seeMoreTapped), for: .touchUpInside)
        
        let titleColor = self.themeManager.currentTheme.type == .dark ? UIColor.white : UIColor.neutralsGray01
        btn.setTitleColor(titleColor, for: .normal)
        self.seeMoreButton = btn
    }
    
    private func addingSubviews() {
        // setup for case when we have both views tabsView & seeMoreButton
        if let tabsView = self.tabsView, let seeMoreButton = self.seeMoreButton {
            self.addSubview(tabsView)
            self.addSubview(seeMoreButton)
            
            tabsView.translatesAutoresizingMaskIntoConstraints = false
            seeMoreButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                tabsView.topAnchor.constraint(equalTo: self.topAnchor),
                tabsView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                tabsView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                
                seeMoreButton.topAnchor.constraint(equalTo: self.topAnchor),
                seeMoreButton.leadingAnchor.constraint(equalTo: tabsView.trailingAnchor),
                seeMoreButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                seeMoreButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
        // setup for case when we have only tabsView
        else if let tabsView = self.tabsView {
            self.addSubview(tabsView)
            tabsView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                tabsView.topAnchor.constraint(equalTo: self.topAnchor),
                tabsView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                tabsView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                tabsView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
        // setup for case when we have only seeMoreButton
        else if let seeMoreButton = self.seeMoreButton {
            self.addSubview(seeMoreButton)
            seeMoreButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                seeMoreButton.topAnchor.constraint(equalTo: self.topAnchor),
                seeMoreButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                seeMoreButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                seeMoreButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
    }
    
    // MARK: - Setup Methods
    
    func applyTheme() {
        self.tabsView?.applyTheme(currentTheme: self.themeManager.currentTheme)
        
        switch self.themeManager.currentTheme.type {
        case .light:
            if self.seeMoreButton != nil {
                self.seeMoreButton?.setTitleColor(UIColor.neutralsGray01, for: .normal)
            }
        case .dark:
            if self.seeMoreButton != nil {
                self.seeMoreButton?.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    
    // MARK: Actions
    
    @objc private func seeMoreTapped() {
        self.delegate?.seeMoreTapped()
    }
}

extension TrendingStoryBtnsView: TrendingStorySegmentedControlViewDelegate {
    func didSelectTab(selectedtab: TrendingStorySegmentControlTabs) {
        switch selectedtab {
        case .articlesBtn:
            self.delegate?.articlesTabDidSelect()
        case .storySummaryBtn:
            self.delegate?.storySummaryTabDidSelect()
        }
    }
}
