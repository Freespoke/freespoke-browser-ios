// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class ToolbarTextField: AutocompleteTextField {
    // MARK: - Variables
    @objc dynamic var clearButtonTintColor: UIColor? {
        didSet {
            // Clear previous tinted image that's cache and ask for a relayout
            tintedClearImage = nil
            setNeedsLayout()
        }
    }

    private var tintedClearImage: UIImage?
    
    private let sizeImgMicrophone: CGSize = CGSize(width: 30, height: 30)
    
    private var imgMicrophoneFrame: CGRect?

    // MARK: - Initializers
    
    private var imgMicrophone: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("DEBUG: Deinit textfield ->")
    }
        
    private func prepareUI() {
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    func addingMicrophoneView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
            guard let self = self else { return }
            guard self.imgMicrophone?.superview == nil else { return }
            guard let window = UIApplication.shared.keyWindowCustom else { fatalError("Something went wrong for key window") }
            guard let point = self.globalFrame else { return }
            let newX = point.minX - self.sizeImgMicrophone.width/2
            let newY = point.maxY - 6
            let imgPoint = CGPoint(x: newX, y: newY)
            
            let imgView = UIImageView()
            imgView.image = UIImage(named: "imgActiveMicrophone")
            self.imgMicrophone = imgView
            
            window.addSubview(self.imgMicrophone!)
            let imgFrame = CGRect(origin: imgPoint, size: self.sizeImgMicrophone)
            self.imgMicrophoneFrame = imgFrame
            self.imgMicrophone?.frame = imgFrame
            self.textFieldDidChange()
        })
    }
    
    @objc func textFieldDidChange() {
        guard let text = self.text else { return }
        guard let imgFrame = self.imgMicrophoneFrame else { return }
        let textSize = (text as NSString).size(withAttributes: [.font: self.font ?? UIFont.systemFont(ofSize: 17)])
        let positionXForClear = self.bounds.width - super.clearButtonRect(forBounds: bounds).minX
        let maxWidth = self.bounds.width - (positionXForClear + super.clearButtonRect(forBounds: bounds).width)
        let clampedX = min(textSize.width, maxWidth)
        let currentY = imgFrame.origin.y + self.sizeImgMicrophone.height / 2
        let currentX = clampedX + (imgFrame.origin.x + self.sizeImgMicrophone.width / 2)
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self = self else { return }
            self.imgMicrophone?.center = CGPoint(x: currentX, y: currentY)
        }
    }
    
    func removeMicrophoneFromSuperView() {
        self.imgMicrophone?.removeFromSuperview()
        self.imgMicrophone = nil
    }
    
    func showFloatingMicrophoneView() {
        self.addingMicrophoneView()
    }
    
    func hideFloatingMicrophoneView() {
        self.removeMicrophoneFromSuperView()
    }

    // MARK: - View setup

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let image = UIImage.templateImageNamed("close-all-text") else { return }//topTabs-closeTabs
        
        if tintedClearImage == nil {
            if let clearButtonTintColor = clearButtonTintColor {
                tintedClearImage = image.tinted(withColor: clearButtonTintColor)
            } else {
                tintedClearImage = image
            }
        }
        // Since we're unable to change the tint color of the clear image, we need to iterate through the
        // subviews, find the clear button, and tint it ourselves.
        // https://stackoverflow.com/questions/55046917/clear-button-on-text-field-not-accessible-with-voice-over-swift
        if let clearButton = value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(tintedClearImage, for: [])
        }
    }

    // The default button size is 19x19, make this larger
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.clearButtonRect(forBounds: bounds)
        let grow: CGFloat = 16
        let rect2 = CGRect(x: rect.minX - grow/2,
                           y: rect.minY - grow/2,
                           width: rect.width + grow,
                           height: rect.height + grow)
        return rect2
    }
}

// MARK: - Theme protocols

extension ToolbarTextField: NotificationThemeable {
    func applyTheme() {
        backgroundColor = .clear
        
        clearButtonTintColor = Utils.hexStringToUIColor(hex: "#9AA2B2")
        
        switch LegacyThemeManager.instance.currentName {
        case .normal:
            textColor = .blackColor
            
        case .dark:
            textColor = .white
        }
        
        tintColor = .redHomeToolbar
    }

    // ToolbarTextField is created on-demand, so the textSelectionColor is a static prop for use when created
    static func applyUIMode(isPrivate: Bool) {
       textSelectionColor = UIColor.legacyTheme.urlbar.textSelectionHighlight(isPrivate)
    }
}

// MARK: - Key commands

extension ToolbarTextField {
    override var keyCommands: [UIKeyCommand]? {
        let commands = [
            UIKeyCommand(action: #selector(handleKeyboardArrowKey(sender:)),
                         input: UIKeyCommand.inputRightArrow),
            UIKeyCommand(action: #selector(handleKeyboardArrowKey(sender:)),
                         input: UIKeyCommand.inputLeftArrow),
        ]
        return commands
    }

    @objc private func handleKeyboardArrowKey(sender: UIKeyCommand) {
        self.selectedTextRange = nil
    }
}
