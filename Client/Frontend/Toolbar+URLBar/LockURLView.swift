// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared

protocol LockURLViewDelegate {
    func tabLocationViewLocationAccessibilityActions() -> [UIAccessibilityCustomAction]?
    func tabLocationViewDidTapShield()
}

final class LockURLView: UIView {
    
    var delegate: LockURLViewDelegate?
    
    lazy var placeholder: NSAttributedString = {
        return NSAttributedString(string: .TabLocationURLPlaceholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.Photon.Grey50])
    }()
    
    private let contentItemsView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var btnTrackingPtotection: LockButton = .build { trackingProtectionButton in
        trackingProtectionButton.addTarget(self, action: #selector(self.didPressTPShieldButton(_:)), for: .touchUpInside)
        trackingProtectionButton.clipsToBounds = false
        trackingProtectionButton.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.trackingProtection
    }
    
    lazy var urlTextField: URLTextField = .build { txt in
        // Prevent the field from compressing the toolbar buttons on the 4S in landscape.
        txt.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 50), for: .horizontal)
        txt.attributedPlaceholder = self.placeholder
        txt.accessibilityIdentifier = "url"
        txt.accessibilityActionsSource = self
        txt.font = UIConstants.DefaultChromeFont
        txt.backgroundColor = .clear
        txt.accessibilityLabel = .TabLocationAddressBarAccessibilityLabel
        txt.font = UIFont.preferredFont(forTextStyle: .body)
        txt.adjustsFontForContentSizeCategory = true
        txt.textAlignment = .center

        // Remove the default drop interaction from the URL text field so that our
        // custom drop interaction on the BVC can accept dropped URLs.
        if let dropInteraction = txt.textDropInteraction {
            txt.removeInteraction(dropInteraction)
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareUI() {  }
    
    private func addingViews() {
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.contentItemsView)
        self.contentItemsView.addSubview(self.btnTrackingPtotection)
        self.contentItemsView.addSubview(self.urlTextField)
    }
    
    private func setupConstraints() {
        
        self.contentItemsView.translatesAutoresizingMaskIntoConstraints = false
        self.btnTrackingPtotection.translatesAutoresizingMaskIntoConstraints = false
        self.urlTextField.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.pinToView(view: self)
      
        NSLayoutConstraint.activate([
            self.contentItemsView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.contentItemsView.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor),
            self.contentItemsView.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor),
            self.contentItemsView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.contentItemsView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            
            self.btnTrackingPtotection.topAnchor.constraint(equalTo: self.contentItemsView.topAnchor, constant: 0),
            self.btnTrackingPtotection.leadingAnchor.constraint(equalTo: self.contentItemsView.leadingAnchor, constant: 0),
            self.btnTrackingPtotection.trailingAnchor.constraint(equalTo: self.urlTextField.leadingAnchor, constant: 0),
            self.btnTrackingPtotection.bottomAnchor.constraint(equalTo: self.contentItemsView.bottomAnchor, constant: 0),
            
            self.urlTextField.topAnchor.constraint(equalTo: self.contentItemsView.topAnchor, constant: 0),
            self.urlTextField.trailingAnchor.constraint(equalTo: self.contentItemsView.trailingAnchor, constant: 0),
            self.urlTextField.bottomAnchor.constraint(equalTo: self.contentItemsView.bottomAnchor, constant: 0),

            self.btnTrackingPtotection.widthAnchor.constraint(equalToConstant: 30),
            self.btnTrackingPtotection.heightAnchor.constraint(equalToConstant: 40),
        
        ])
    }
    
    @objc func didPressTPShieldButton(_ button: UIButton) {
        self.delegate?.tabLocationViewDidTapShield()
    }
    
    func updateURL(url: URL?) {
        self.urlTextField.text = url?.host
    }
    
    func applyTheme() {
        switch LegacyThemeManager.instance.currentName {
        case .normal:
            urlTextField.textColor = UIColor.blackColor
            
        case .dark:
            urlTextField.textColor = UIColor.white
        }
        btnTrackingPtotection.applyTheme()
    }
    
    func updateBlockerStatus(forTab tab: Tab) {
        guard let blocker = tab.contentBlocker else { return }
        btnTrackingPtotection.alpha = 1.0

        var lockImage: UIImage?
        // TODO: FXIOS-5101 Use theme.type.getThemedImageName()
        let imageID = LegacyThemeManager.instance.currentName == .dark ? "lock_blocked_dark" : "lock_blocked"
        if !(tab.webView?.hasOnlySecureContent ?? false) {
            lockImage = UIImage(imageLiteralResourceName: imageID)
        } else if let tintColor = btnTrackingPtotection.tintColor {
            lockImage = UIImage(imageLiteralResourceName: ImageIdentifiers.lockVerifed)
                .withTintColor(tintColor, renderingMode: .alwaysTemplate)
        }

        switch blocker.status {
        case .blocking, .noBlockedURLs:
            btnTrackingPtotection.setImage(lockImage, for: .normal)
        case .safelisted:
            btnTrackingPtotection.setImage(lockImage?.overlayWith(image: UIImage(imageLiteralResourceName: "MarkAsRead")), for: .normal)
        case .disabled:
            btnTrackingPtotection.setImage(lockImage, for: .normal)
        }
    }
    
    func shouldHideProtectionBtn(isHidden: Bool) {
        self.btnTrackingPtotection.isHidden = isHidden
        self.urlTextField.updateTextRect(isSpecial: isHidden)
        
    }
}

extension LockURLView: AccessibilityActionsSource {
    func accessibilityCustomActionsForView(_ view: UIView) -> [UIAccessibilityCustomAction]? {
        if view === urlTextField {
            return delegate?.tabLocationViewLocationAccessibilityActions()
        }
        return nil
    }
}
