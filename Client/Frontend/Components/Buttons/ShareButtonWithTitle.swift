// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class ShareButtonWithTitle: BaseTouchableButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        self.backgroundColor = UIColor.clear // Set the background color directly
        
        // Create a UIButton.Configuration
        var config = UIButton.Configuration.filled()
        config.title = "SHARE"
        config.baseForegroundColor = .greenColor
        config.baseBackgroundColor = UIColor.clear
        
        // Set font and other title properties
        var titleAttr = AttributedString("SHARE")
        titleAttr.font = UIFont.sourceSansProFont(.bold, size: 14)
        config.attributedTitle = titleAttr
        
        // Set the image
        if let arrowImage = UIImage(named: "imgUpload")?.withTintColor(.greenColor, renderingMode: .alwaysOriginal) {
            config.image = arrowImage
            config.imagePlacement = .trailing
            config.imagePadding = 8 // Space between text and image
        }
        
        // Set content insets
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
        
        self.tintColor = UIColor.greenColor
        
        self.configuration = config
        
        self.contentHorizontalAlignment = .trailing
        self.contentVerticalAlignment = .center
        
        // Ensure the button maintains the same appearance for different states
        self.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration
            var titleAttr = AttributedString("SHARE")
            titleAttr.font = UIFont.sourceSansProFont(.bold, size: 14)
            titleAttr.foregroundColor = .greenColor
            updatedConfig?.attributedTitle = titleAttr
            updatedConfig?.baseBackgroundColor = UIColor.clear
            
            // Explicitly set background for different states
            updatedConfig?.background.backgroundColor = .clear
            updatedConfig?.background.strokeColor = .clear
            updatedConfig?.background.strokeWidth = 0
            
            button.configuration = updatedConfig
        }
    }
}
