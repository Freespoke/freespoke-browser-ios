// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

protocol HomepageTopSubHeaderViewDelegate: AnyObject {
    func didTapLearnMore()
}

class HomepageTopSubHeaderView: UIView {
    // MARK: - Properties
    
    weak var delegate: HomepageTopSubHeaderViewDelegate?
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
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
        
        // Add the tap gesture recognizer once during initialization
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.lblTitle.isUserInteractionEnabled = true
        self.lblTitle.addGestureRecognizer(tapGesture)
    }
    
    func applyTheme(currentTheme: Theme) {
        self.setupText(currentTheme: currentTheme)
    }
}

// MARK: - Add Subviews

extension HomepageTopSubHeaderView {
    private func addSubviews() {
        self.addSubview(self.lblTitle)
    }
    
    private func addSubviewsConstraints() {
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.lblTitle.pinToView(view: self)
    }
    
    private func setupText(currentTheme: Theme) {
        let fullText = "Search Beyond the Bias. Learn more"
        
        let getTheFullPictureRange = (fullText as NSString).range(of: "Search Beyond the Bias. ")
        let learnMoreRange = (fullText as NSString).range(of: "Learn more")
        
        let attributedText = NSMutableAttributedString(string: fullText)
        
        // Set font
        attributedText.addAttribute(.font,
                                    value: UIFont.sourceSerifProFontFont(.semiBold, size: 15),
                                    range: getTheFullPictureRange)
        
        attributedText.addAttribute(.font,
                                    value: UIFont.sourceSerifProFontFont(.regularItalic, size: 15),
                                    range: learnMoreRange)
        
        // Set the color based on the current theme
        let textColor: UIColor = currentTheme.type == .dark ? .white : .onboardingTitleDark
        attributedText.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: fullText.count))
        
        self.lblTitle.attributedText = attributedText
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let text = (self.lblTitle.attributedText?.string ?? "") as NSString
        let learnMoreRange = text.range(of: "Learn more")
        
        if gesture.didTapAttributedTextInLabel(label: self.lblTitle, inRange: learnMoreRange) {
            self.didTapLearnMore()
        }
    }
    
    private func didTapLearnMore() {
        self.delegate?.didTapLearnMore()
    }
}
