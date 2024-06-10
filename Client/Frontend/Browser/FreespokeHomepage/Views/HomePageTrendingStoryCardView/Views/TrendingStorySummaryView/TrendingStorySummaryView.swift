// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class TrendingStorySummaryView: UIView {
    // MARK: - Properties
    
    private let topView: StorySummaryTopView = {
        let view = StorySummaryTopView()
        return view
    }()
    
    private let summaryTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.sourceSansProFont(.regular, size: 15)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = [.link]
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.brand600BlueLead]
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    private var overlayView: StorySummaryOverlayView = {
        let view = StorySummaryOverlayView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private var summary: String = ""
    
    private var defaultTextViewHeight: CGFloat = 325 // without sorces in summary view
    
    private var summaryTextViewHeightConstraint: NSLayoutConstraint?
    
    private var currentTheme: Theme?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        self.addSubview(self.topView)
        self.addSubview(self.summaryTextView)
        self.addSubview(self.overlayView)
        
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        self.summaryTextView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        self.summaryTextViewHeightConstraint = self.heightAnchor.constraint(equalToConstant: self.defaultTextViewHeight)
        self.summaryTextViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            self.topView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            self.topView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.topView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            self.summaryTextView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 18),
            self.summaryTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.summaryTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.summaryTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            
            self.overlayView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.overlayView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.overlayView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.overlayView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func applyTheme(currentTheme: Theme) {
        self.currentTheme = currentTheme
        self.topView.applyTheme(currentTheme: currentTheme)
        self.updateAttributedText()
        self.overlayView.applyTheme(currentTheme: currentTheme)
    }
    
    private func showCollapsedState() {
        self.showOverlayViewWithReadMoreButton()
        self.summaryTextViewHeightConstraint?.isActive = true
        
        self.overlayView.btnReadMoreTappedClosure = { [weak self] in
            self?.showExpandedState()
        }
    }
    
    private func showExpandedState() {
        self.hideOverlayViewWithReadMoreButton()
        self.summaryTextViewHeightConstraint?.isActive = false
    }
    private func showOverlayViewWithReadMoreButton() {
        self.overlayView.isHidden = false
    }
    
    private func hideOverlayViewWithReadMoreButton() {
        self.overlayView.isHidden = true
    }
    
    func configure(with summary: String, sources: [String] = []) {
        self.summary = summary
        self.topView.configure(sources: sources)
        
        if let attributedString = self.htmlToAttributedString(html: self.summary) {
            let styledAttributedString = self.applyParagraphStyle(to: attributedString,
                                                                  currentTheme: self.currentTheme)
            self.summaryTextView.attributedText = styledAttributedString
        } else {
            self.summaryTextView.text = summary
        }
        self.showCollapsedState()
    }
    
    private func updateAttributedText() {
        if let attributedString = self.htmlToAttributedString(html: summary) {
            let styledAttributedString = self.applyParagraphStyle(to: attributedString,
                                                                  currentTheme: self.currentTheme)
            self.summaryTextView.attributedText = styledAttributedString
        } else {
            self.summaryTextView.text = summary
        }
    }
    
    private func htmlToAttributedString(html: String) -> NSAttributedString? {
        guard let data = html.data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("Error converting HTML to NSAttributedString: \(error)")
            return nil
        }
    }
    
    private func applyParagraphStyle(to attributedString: NSAttributedString, currentTheme: Theme?) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 22.5 - (self.summaryTextView.font?.lineHeight ?? 0) // Adjust line spacing to achieve 22.5 px line height
        paragraphStyle.paragraphSpacing = 8
        
        mutableAttributedString.addAttribute(NSAttributedString.Key.font,
                                             value: UIFont.sourceSansProFont(.regular, size: 15),
                                             range: NSRange(location: 0, length: mutableAttributedString.length))
        
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                             value: currentTheme?.type == .dark ? UIColor.white : UIColor.neutralsGray01,
                                             range: NSRange(location: 0,
                                                            length: mutableAttributedString.length))
        
        mutableAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: mutableAttributedString.length))
        
        return mutableAttributedString
    }
}
