// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

protocol TrendingStorySegmentedControlViewDelegate: AnyObject {
    //    func didSelectTab(at index: Int)
    func didSelectTab(selectedtab: TrendingStorySegmentControlTabs)
}

enum TrendingStorySegmentControlTabs {
    case articlesBtn
    case storySummaryBtn
    
    var title: String {
        switch self {
        case .articlesBtn:
            return "Articles"
        case .storySummaryBtn:
            return "Story Summary"
        }
    }
}

class TrendingStorySegmentedControlView: UIView {
    // MARK: - Properties
    
    weak var delegate: TrendingStorySegmentedControlViewDelegate?
    
    private let stackView = UIStackView()
    private let underlineView = UIView()
    
    //    private let titles: [String]
    let tabs: [TrendingStorySegmentControlTabs]
    
    private var labels: [UILabel] = []
    private var selectedIndex: Int = 0
    
    private var currentTheme: Theme?
    
    // MARK: - Initializers
    
    init(tabs: [TrendingStorySegmentControlTabs]) {
        self.tabs = tabs
        super.init(frame: .zero)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.setupStackView()
        self.setupUnderlineView()
        self.setupLabels()
        self.setupSwipeGestures()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.selectTab(at: self.selectedIndex, animated: false)
        let selectedTab = self.tabs[self.selectedIndex]
        self.delegate?.didSelectTab(selectedtab: selectedTab)
        //        self.delegate?.didSelectTab(at: self.selectedIndex)
    }
    
    // MARK: - Setup Methods
    
    private func setupStackView() {
        self.stackView.axis = .horizontal
        self.stackView.distribution = .fillEqually
        self.stackView.alignment = .fill
        self.stackView.spacing = 10
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.stackView)
        
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.stackView.heightAnchor.constraint(equalToConstant: 40),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func setupUnderlineView() {
        self.underlineView.backgroundColor = UIColor.brand600BlueLead
        self.underlineView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.underlineView)
    }
    
    private func setupLabels() {
        for (index, tab) in tabs.enumerated() {
            let label = UILabel()
            label.font = UIFont.sourceSansProFont(.semiBold, size: 16)
            label.text = tab.title
            label.textAlignment = .center
            
            label.textColor = index == self.selectedIndex ? UIColor.brand600BlueLead : UIColor.neutralsGray01
            label.isUserInteractionEnabled = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
            label.addGestureRecognizer(tapGesture)
            
            self.stackView.addArrangedSubview(label)
            self.labels.append(label)
        }
    }
    
    private func updateLabelsTextColors() {
        for (index, label) in self.labels.enumerated() {
            let unselectedTextColor = self.currentTheme?.type == .dark ? UIColor.white : UIColor.neutralsGray01
            label.textColor = index == self.selectedIndex ? UIColor.brand600BlueLead : unselectedTextColor
        }
    }
    
    // MARK: - Swipe Gestures
    
    private func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        swipeLeft.direction = .left
        self.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        swipeRight.direction = .right
        self.addGestureRecognizer(swipeRight)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if self.selectedIndex < labels.count - 1 {
                self.selectTab(at: self.selectedIndex + 1, animated: true)
                let selectedTab = self.tabs[self.selectedIndex]
                self.delegate?.didSelectTab(selectedtab: selectedTab)
            }
        } else if gesture.direction == .right {
            if self.selectedIndex > 0 {
                self.selectTab(at: self.selectedIndex - 1, animated: true)
                let selectedTab = self.tabs[self.selectedIndex]
                self.delegate?.didSelectTab(selectedtab: selectedTab)
            }
        }
    }
    
    // MARK: - Action Methods
    
    @objc private func labelTapped(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel, let index = labels.firstIndex(of: label) else {
            return
        }
        self.selectTab(at: index, animated: true)
        let selectedTab = self.tabs[self.selectedIndex]
        self.delegate?.didSelectTab(selectedtab: selectedTab)
    }
    
    // MARK: - Helper Methods
    
    func selectTab(at index: Int, animated: Bool, spacing: CGFloat = 0.0) {
        guard index >= 0 && index < self.labels.count else {
            return
        }
        
        let label = labels[index]
        let underlineFrame = label.frame
        
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.underlineView.frame = CGRect(x: underlineFrame.minX,
                                              y: self.bounds.height - 2 - spacing,
                                              width: underlineFrame.width,
                                              height: 2)
            let unselectedTextColor = self.currentTheme?.type == .dark ? UIColor.white : UIColor.neutralsGray01
            self.labels[self.selectedIndex].textColor = unselectedTextColor
            label.textColor = .brand600BlueLead
        }
        
        self.selectedIndex = index
    }
    
    func applyTheme(currentTheme: Theme) {
        self.currentTheme = currentTheme
        
        self.updateLabelsTextColors()
    }
}
