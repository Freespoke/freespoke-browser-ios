// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

protocol RightToolBarViewDelegate {
    func tabLocationViewDidTapBookmarkBtn(button: UIButton)
    func tabLocationViewTapShare(button: UIButton)
    func tabLocationViewTapMicrophoneButton(button: UIButton)
    func tabLocationViewDidTapReload()
    func tabLocationViewDidLongPressReload(button: UIButton)
}

enum RigthToolBarTypeBtnsHidden {
    case all(isHidden: Bool)
}

final class RightToolBarView: UIView {
    
    var delegate: RightToolBarViewDelegate?
    
    let sizeForBtns: CGSize = CGSize(width: 40, height: 40)
    let spacing: CGFloat = 0
    
    private var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        return sv
    }()
    
    lazy var btnBookmark: BookmarkButton = .build { bookmarkButton in
        bookmarkButton.addTarget(self, action: #selector(self.didPressOnBtnBookmark(_:)), for: .touchUpInside)
        bookmarkButton.clipsToBounds = false
        bookmarkButton.tintColor = UIColor.Photon.Grey50
        bookmarkButton.contentHorizontalAlignment = .center
        bookmarkButton.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.bookmarkButton
        bookmarkButton.isHidden = true
    }

    lazy private var btnReload: StatefulButton = {
        let reloadButton = StatefulButton(frame: .zero, state: .disabled)
        reloadButton.addTarget(self, action: #selector(tapOnBtnReload), for: .touchUpInside)
        reloadButton.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(longPressOnBtnReload)))
        reloadButton.tintColor = UIColor.Photon.Grey50
        reloadButton.imageView?.contentMode = .scaleAspectFit
        reloadButton.contentHorizontalAlignment = .center
        reloadButton.accessibilityLabel = .TabLocationReloadAccessibilityLabel
        reloadButton.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.reloadButton
        reloadButton.isAccessibilityElement = true
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.isHidden = true
        return reloadButton
    }()
    
    lazy var btnShare: ShareButton = .build {  [weak self] shareButton in
        guard let self = self else { return }
        shareButton.addTarget(self, action: #selector(self.didPressOnBtnShare(_:)), for: .touchUpInside)
        shareButton.clipsToBounds = false
        shareButton.tintColor = UIColor.Photon.Grey50
        shareButton.contentHorizontalAlignment = .center
        shareButton.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.shareButton
        shareButton.isHidden = true
    }
    
    lazy var btnMicrophone: MicrophoneButton = {
        let btn = MicrophoneButton()
        btn.addTarget(self, action: #selector(self.didPressMicrophoneButton(_:)), for: .touchUpInside)
        btn.clipsToBounds = false
        btn.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.microphoneButton
        btn.isHidden = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareUI() {
        
    }
    
    private func addingViews() {
        self.addSubviews(self.stackView)
        self.stackView.addArrangedSubview(self.btnBookmark)
        self.stackView.addArrangedSubview(self.btnReload)
        self.stackView.addArrangedSubview(self.btnShare)
        self.stackView.addArrangedSubview(self.btnMicrophone)
    }
    
    private func setupConstraints() {
        self.stackView.pinToView(view: self)
        self.btnBookmark.setSizeToView(width: self.sizeForBtns.width, height: self.sizeForBtns.height)
        self.btnReload.setSizeToView(width: self.sizeForBtns.width, height: self.sizeForBtns.height)
        self.btnShare.setSizeToView(width: self.sizeForBtns.width, height: self.sizeForBtns.height)
        self.btnMicrophone.setSizeToView(width: self.sizeForBtns.width, height: self.sizeForBtns.height)
    }
    
    @objc func didPressOnBtnBookmark(_ button: UIButton) {
        self.delegate?.tabLocationViewDidTapBookmarkBtn(button: button)
    }
    
    @objc func didPressOnBtnShare(_ button: UIButton) {
        self.delegate?.tabLocationViewTapShare(button: button)
    }
    
    @objc func didPressMicrophoneButton(_ button: UIButton) {
        self.delegate?.tabLocationViewTapMicrophoneButton(button: button)
    }
    
    @objc func tapOnBtnReload() {
        self.delegate?.tabLocationViewDidTapReload()
    }
    
    @objc func longPressOnBtnReload(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            self.delegate?.tabLocationViewDidLongPressReload(button: self.btnReload)
        }
    }
    
    func shouldHideBtns(typeBtns: RigthToolBarTypeBtnsHidden) {
        switch typeBtns {
        case .all(let isHidden):
            self.btnShare.isHidden = isHidden
            self.btnReload.isHidden = isHidden
            self.btnBookmark.isHidden = isHidden
        }
    }
    
    func getHiddenValueForBtnReload() -> Bool {
        return self.btnReload.isHidden
    }
    
    func getStatusForBtnReload() -> ReloadButtonState {
        return self.btnReload.reloadButtonState
    }
    
    func updateStatusForReloadBtn(status: ReloadButtonState) {
        self.btnReload.reloadButtonState = status
    }
}
