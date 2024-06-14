// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Common
import UIKit
import Shared

protocol TabLocationViewDelegate: AnyObject {
    func tabLocationViewDidTapLocation(_ tabLocationView: TabLocationView)
    func tabLocationViewDidLongPressLocation(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTapReaderMode(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTapReload(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTapShield(_ tabLocationView: TabLocationView)
    func tabLocationViewDidBeginDragInteraction(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTapBookmarkBtn(_ tabLocationView: TabLocationView, button: UIButton)
    func tabLocationViewTapMicrophoneButton(_ tabLocationView: TabLocationView)
    func tabLocationViewTapShare(_ tabLocationView: TabLocationView, button: UIButton)

    /// - returns: whether the long-press was handled by the delegate; i.e. return `false` when the conditions for even starting handling long-press were not satisfied
    @discardableResult func tabLocationViewDidLongPressReaderMode(_ tabLocationView: TabLocationView) -> Bool
    func tabLocationViewDidLongPressReload(_ tabLocationView: TabLocationView, button: UIButton)
    func tabLocationViewLocationAccessibilityActions(_ tabLocationView: TabLocationView) -> [UIAccessibilityCustomAction]?
}

class TabLocationView: UIView, FeatureFlaggable {
    // MARK: UX
    struct UX {
        static let hostFontColor = UIColor.black
        static let baseURLFontColor = UIColor.Photon.Grey50
        static let spacing: CGFloat = 8
        static let statusIconSize: CGFloat = 18
        static let buttonSize: CGFloat = 40
        static let urlBarPadding = 4
    }

    // MARK: Variables
    var delegate: TabLocationViewDelegate?
    var longPressRecognizer: UILongPressGestureRecognizer!
    var tapRecognizer: UITapGestureRecognizer!
   
    var contentMainStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        return sv
    }()

    private let menuBadge = BadgeWithBackdrop(imageName: ImageIdentifiers.menuBadge, backdropCircleSize: 32)

    @objc dynamic var baseURLFontColor: UIColor = UX.baseURLFontColor {
        didSet {
            updateTextWithURL()
        }
    }

    var url: URL? {
        didSet {
            updateTextWithURL()
            self.lockURLView.shouldHideProtectionBtn(isHidden: !isValidHttpUrlProtocol)
            setNeedsUpdateConstraints()
        }
    }

    var shouldEnableShareButtonFeature: Bool {
        guard featureFlags.isFeatureEnabled(.shareToolbarChanges, checking: .buildOnly) else {
            return false
        }
        return true
    }

    var readerModeState: ReaderModeState {
        get {
            return btnReaderMode.readerModeState
        }
        set (newReaderModeState) {
            guard newReaderModeState != self.btnReaderMode.readerModeState else { return }
            setReaderModeState(newReaderModeState)
        }
    }

    lazy var lockURLView: LockURLView = .build({ lockURLView in
        lockURLView.delegate = self
    })

    private lazy var btnReaderMode: ReaderModeButton = .build { [weak self] readerModeButton in
        guard let self = self else { return }
        readerModeButton.addTarget(self, action: #selector(self.tapReaderModeButton(_:)), for: .touchUpInside)
        readerModeButton.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self,
                                         action: #selector(self.longPressReaderModeButton)))
        readerModeButton.isAccessibilityElement = true
        readerModeButton.isHidden = true
        readerModeButton.accessibilityLabel = .TabLocationReaderModeAccessibilityLabel
        readerModeButton.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.readerModeButton
        readerModeButton.accessibilityCustomActions = [
            UIAccessibilityCustomAction(
                name: .TabLocationReaderModeAddToReadingListAccessibilityLabel,
                target: self,
                selector: #selector(self.readerModeCustomAction))]
    }
    
    lazy var rightToolBarView: RightToolBarView = .build { [weak self] rightToolBarView in
        rightToolBarView.delegate = self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        register(self, forTabEvents: .didGainFocus, .didToggleDesktopMode, .didChangeContentBlocking)

        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressLocation))
        longPressRecognizer.delegate = self

        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLocation))
        tapRecognizer.delegate = self

        addGestureRecognizer(longPressRecognizer)
        addGestureRecognizer(tapRecognizer)

        let space1px = UIView.build()
        space1px.widthAnchor.constraint(equalToConstant: 1).isActive = true

        let subviews = [btnReaderMode, lockURLView, rightToolBarView]
        
        subviews.forEach({ [weak self] in self?.contentMainStackView.addArrangedSubview($0) })
        
        contentMainStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentMainStackView)

        contentMainStackView.pinToView(view: self, withInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        let countItems: CGFloat = CGFloat(subviews.count)
        let width = self.rightToolBarView.sizeForBtns.width
        let spacing = self.rightToolBarView.spacing
        
        let partItemsSpcing = ((countItems - 1) * spacing)
        let partItemWidth = (countItems * width) + UX.buttonSize
        let totalWidth = partItemWidth + partItemsSpcing

        let widthForLockUrlView = UIScreen.main.bounds.width - totalWidth
        
        NSLayoutConstraint.activate([
            btnReaderMode.widthAnchor.constraint(equalToConstant: UX.buttonSize),
            btnReaderMode.heightAnchor.constraint(equalToConstant: UX.buttonSize),
        ])
        
        self.lockURLView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.lockURLView.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])

        btnReaderMode.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rightToolBarView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        lockURLView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lockURLView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Setup UIDragInteraction to handle dragging the location
        // bar for dropping its URL into other apps.
        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.allowsSimultaneousRecognitionDuringLift = true
        self.addInteraction(dragInteraction)

        menuBadge.add(toParent: contentMainStackView)
        menuBadge.show(false)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Accessibility

    private lazy var _accessibilityElements = [btnReaderMode, lockURLView, rightToolBarView]

    override var accessibilityElements: [Any]? {
        get {
            return _accessibilityElements.filter { !$0.isHidden }
        }
        set {
            super.accessibilityElements = newValue
        }
    }

    func overrideAccessibility(enabled: Bool) {
        _accessibilityElements.forEach {
            $0.isAccessibilityElement = enabled
        }
    }

    // MARK: - User actions

    @objc func tapReaderModeButton(_ button: UIButton) {
        delegate?.tabLocationViewDidTapReaderMode(self)
    }

    @objc func longPressReaderModeButton(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            delegate?.tabLocationViewDidLongPressReaderMode(self)
        }
    }

    @objc func longPressLocation(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .began {
            delegate?.tabLocationViewDidLongPressLocation(self)
        }
    }

    @objc func tapLocation(_ recognizer: UITapGestureRecognizer) {
        delegate?.tabLocationViewDidTapLocation(self)
    }

    @objc func readerModeCustomAction() -> Bool {
        return delegate?.tabLocationViewDidLongPressReaderMode(self) ?? false
    }

    private func updateTextWithURL() {
        self.lockURLView.updateURL(url: self.url)
    }
    
    func shouldHideButtons(typeBtns: RigthToolBarTypeBtnsHidden) {
        self.rightToolBarView.shouldHideBtns(typeBtns: typeBtns)
        switch typeBtns {
        case .all(let isHidden):
            self.btnReaderMode.isHidden = isHidden
        case .bookmarksAndReload(isHidden: let isHidden):
            break
        }
    }
}

extension TabLocationView: LockURLViewDelegate {
    func tabLocationViewLocationAccessibilityActions() -> [UIAccessibilityCustomAction]? {
        return self.delegate?.tabLocationViewLocationAccessibilityActions(self)
    }
    
    func tabLocationViewDidTapShield() {
        self.delegate?.tabLocationViewDidTapShield(self)
    }
}

extension TabLocationView: RightToolBarViewDelegate {
    func tabLocationViewTapMicrophoneButton(button: UIButton) {
        self.delegate?.tabLocationViewTapMicrophoneButton(self)
    }
    
    func tabLocationViewDidTapBookmarkBtn(button: UIButton) {
        self.delegate?.tabLocationViewDidTapBookmarkBtn(self, button: button)
    }
    
    func tabLocationViewTapShare(button: UIButton) {
        self.delegate?.tabLocationViewTapShare(self, button: button)
    }
    
    func tabLocationViewDidTapReload() {
        self.delegate?.tabLocationViewDidTapReload(self)
    }
    
    func tabLocationViewDidLongPressReload(button: UIButton) {
        self.delegate?.tabLocationViewDidLongPressReload(self, button: button)
    }
}
// MARK: - Private
private extension TabLocationView {
    var isValidHttpUrlProtocol: Bool {
        ["https", "http"].contains(url?.scheme ?? "")
    }

    func setReaderModeState(_ newReaderModeState: ReaderModeState) {
        let wasHidden = btnReaderMode.isHidden
        self.btnReaderMode.readerModeState = newReaderModeState
        self.btnReaderMode.isHidden = (newReaderModeState == ReaderModeState.unavailable)
        if wasHidden != btnReaderMode.isHidden {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: nil)
            if !btnReaderMode.isHidden {
                // Delay the Reader Mode accessibility announcement briefly to prevent interruptions.
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: String.ReaderModeAvailableVoiceOverAnnouncement)
                }
            }
        }
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.btnReaderMode.alpha = newReaderModeState == .unavailable ? 0 : 1
        })
    }
}

extension TabLocationView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // When long pressing a button make sure the textfield's long press gesture is not triggered
        return !(otherGestureRecognizer.view is UIButton)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // If the longPressRecognizer is active, fail the tap recognizer to avoid conflicts.
        return gestureRecognizer == longPressRecognizer && otherGestureRecognizer == tapRecognizer
    }
}

extension TabLocationView: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        // Ensure we actually have a URL in the location bar and that the URL is not local.
        guard let url = self.url,
              !InternalURL.isValid(url: url),
              let itemProvider = NSItemProvider(contentsOf: url)
        else { return [] }

        TelemetryWrapper.recordEvent(category: .action, method: .drag, object: .locationBar)

        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }

    func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession) {
        delegate?.tabLocationViewDidBeginDragInteraction(self)
    }
}

extension TabLocationView: NotificationThemeable {
    func applyTheme() {
        self.lockURLView.applyTheme()
        btnReaderMode.applyTheme()
        let color = LegacyThemeManager.instance.currentName == .dark ? UIColor(white: 0.3, alpha: 0.6): UIColor.legacyTheme.textField.background
        menuBadge.badge.tintBackground(color: color)
    }
}

extension TabLocationView: TabEventHandler {
    func tabDidChangeContentBlocking(_ tab: Tab) {
        updateBlockerStatus(forTab: tab)
    }

    private func updateBlockerStatus(forTab tab: Tab) {
        assertIsMainThread("UI changes must be on the main thread")
        self.lockURLView.updateBlockerStatus(forTab: tab)
    }

    func tabDidGainFocus(_ tab: Tab) {
        updateBlockerStatus(forTab: tab)
    }
}
