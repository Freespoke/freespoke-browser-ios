// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class BaseButtonStylesModel {
    var backgroundColorEnableState: UIColor
    var backgroundColorNotEnableState: UIColor
    
    var font: UIFont
    
    var fontColorEnableState: UIColor
    var fontColorNotEnableState: UIColor
    
    var borderColorEnableState: CGColor?
    var borderColorNotEnableState: CGColor?
    
    var borderWidthEnableState: CGFloat?
    var borderWidthDisabledState: CGFloat?
    
    var activityIndicatorColor: UIColor
    
    init(backgroundColorEnableState: UIColor,
         backgroundColorNotEnableState: UIColor,
         
         font: UIFont,
         
         fontColorEnableState: UIColor,
         fontColorNotEnableState: UIColor,
         
         borderColorEnableState: CGColor?,
         borderColorNotEnableState: CGColor?,
         
         borderWidthEnableState: CGFloat?,
         borderWidthDisabledState: CGFloat?,
         activityIndicatorColor: UIColor) {
        self.backgroundColorEnableState = backgroundColorEnableState
        self.backgroundColorNotEnableState = backgroundColorNotEnableState
        
        self.font = font
        
        self.fontColorEnableState = fontColorEnableState
        self.fontColorNotEnableState = fontColorNotEnableState
        
        self.borderColorEnableState = borderColorEnableState
        self.borderColorNotEnableState = borderColorNotEnableState
        
        self.borderWidthEnableState = borderWidthEnableState
        self.borderWidthDisabledState = borderWidthDisabledState
        self.activityIndicatorColor = activityIndicatorColor
    }
}
