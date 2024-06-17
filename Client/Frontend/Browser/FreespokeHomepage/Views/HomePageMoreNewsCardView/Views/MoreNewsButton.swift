// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Common

class MoreNewsButton: BaseTouchableButton, Themeable {
    var themeManager: ThemeManager = AppContainer.shared.resolve()
    var notificationCenter: NotificationProtocol = NotificationCenter.default
    var themeObserver: NSObjectProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupButton()
        self.listenForThemeChange(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.applyTheme()
    }
    
    private func setupButton() {
        self.backgroundColor = UIColor.greenColor // Set the background color directly
        
        // Create a UIButton.Configuration
        var config = UIButton.Configuration.filled()
        config.title = "More News"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor.greenColor
        
        // Set font and other title properties
        var titleAttr = AttributedString("More News")
        titleAttr.font = UIFont.sourceSansProFont(.semiBold, size: 16) // Adjust font as necessary
        config.attributedTitle = titleAttr
        
        // Set the image
        if let arrowImage = UIImage(named: "more_news_button_arrow_image") {
            config.image = arrowImage
            config.imagePlacement = .trailing
            config.imagePadding = 8 // Space between text and image
        }
        
        // Set content insets
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
        
        self.configuration = config
        
        // Round the corners
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    func applyTheme() {
        switch self.themeManager.currentTheme.type {
        case .light:
            self.configuration?.baseForegroundColor = .white
            self.configuration?.baseBackgroundColor = UIColor.greenColor
        case .dark:
            self.configuration?.baseForegroundColor = .white
            self.configuration?.baseBackgroundColor = UIColor.greenColor
        }
    }
}
