// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Common

class MicrophoneButton: BaseTouchableButton, Themeable {
    var themeManager: ThemeManager
    var notificationCenter: NotificationProtocol
    var themeObserver: NSObjectProtocol?
    
    override var isEnabled: Bool {
        didSet {
            self.applyTheme()
        }
    }
    
    init(themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default) {
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        super.init(frame: .zero)
        self.commonInit()
        
        self.listenForThemeChange(self)
        self.applyTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.setMicTurnOnStyle()
        self.clipsToBounds = false
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    func applyTheme() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch self.isEnabled {
            case true:
                self.tintColor = self.themeManager.currentTheme.type == .dark ? UIColor.white : UIColor.neutralsGray01
            case false:
                self.tintColor = self.themeManager.currentTheme.type == .dark ? UIColor.white.withAlphaComponent(0.5) : UIColor.neutralsGray01.withAlphaComponent(0.5)
            }
        }
    }
    
    func setMicTurnOnStyle() {
        self.setImage(UIImage.templateImageNamed(ImageIdentifiers.imgMicrophoneTurnOn), for: .normal)
        self.applyTheme()
    }
    
    func setMicTurnOffStyle() {
        self.setImage(UIImage.templateImageNamed(ImageIdentifiers.imgMicrophoneTurnOff), for: .normal)
        self.applyTheme()
    }
}
