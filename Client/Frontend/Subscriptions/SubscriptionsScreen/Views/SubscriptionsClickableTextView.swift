// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class SubscriptionsClickableTextView: UITextView {
    private let originalText = "By selecting a plan below for a monthly or yearly subscription you are enrolling in automatic payments after the 30-day trial period. You can cancel your plan anytime, effective at end of billing period. For more information see our Terms Page."
    
    private var termsPageUrl: String {
        return "http://www.apple.com/legal/itunes/appstore/dev/stdeula"
    }
    
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = CGSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        let newSize = sizeThatFits(size)
        return CGSize(width: newSize.width, height: newSize.height)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.configureTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTextView() {
        self.isEditable = false
        self.dataDetectorTypes = .link
        self.isScrollEnabled = false
        self.textContainer.lineFragmentPadding = 0
        
        self.backgroundColor = .clear
        self.autocorrectionType = .no
        
        self.isUserInteractionEnabled = true
        self.delegate = self
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    func applyTheme(currentTheme: Theme) {
        self.updateAttributedtext(originalText: self.originalText,
                                  hyperLinks: ["Terms Page": self.termsPageUrl],
                                  currentTheme: currentTheme)
    }
    
    private func updateAttributedtext(originalText: String, hyperLinks: [String: String], currentTheme: Theme) {
        let style = NSMutableParagraphStyle()
        style.alignment = .justified
        let attributedOriginalText = NSMutableAttributedString(string: originalText)
        for (hyperLink, urlString) in hyperLinks {
            let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
            let fullRange = NSRange(location: 0, length: attributedOriginalText.length)
            attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString, range: linkRange)
            attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
            attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont.sourceSansProFont(.regular, size: 13), range: fullRange)
            attributedOriginalText.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: (currentTheme.type == .dark) ? UIColor.lightGray : UIColor.gray2,
                range: fullRange
            )
        }
        
        self.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.greenColor,
            NSAttributedString.Key.font: UIFont.sourceSansProFont(.bold, size: 13)
        ]
        self.attributedText = attributedOriginalText
    }
}

extension SubscriptionsClickableTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
}
