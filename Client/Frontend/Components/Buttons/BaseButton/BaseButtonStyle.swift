// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

enum BaseButtonStyle {
    case greenStyle(currentTheme: Theme?)
    case clearStyle(currentTheme: Theme?)
    case greyStyle(currentTheme: Theme?)
    
    var settings: BaseButtonStylesModel {
        switch self {
        case .greenStyle(let currentTheme):
            return BaseButtonStylesModel(
                backgroundColorEnableState: currentTheme?.type == .dark ? UIColor.greenColor : UIColor.greenColor,
                backgroundColorNotEnableState: currentTheme?.type == .dark ? UIColor.greenColor.withAlphaComponent(0.5) : UIColor.greenColor.withAlphaComponent(0.5),
                
                font: .sourceSansProFont(.semiBold, size: 18),
                
                fontColorEnableState: UIColor.white,
                fontColorNotEnableState: UIColor.white.withAlphaComponent(0.5),
                
                borderColorEnableState: nil,
                borderColorNotEnableState: nil,
                
                borderWidthEnableState: 0,
                borderWidthDisabledState: 0,
                activityIndicatorColor: UIColor.black
            )
        case .clearStyle(let currentTheme):
            return BaseButtonStylesModel(
                backgroundColorEnableState: UIColor.clear,
                backgroundColorNotEnableState: UIColor.clear.withAlphaComponent(0.5),
                
                font: .sourceSansProFont(.regular, size: 18),
                
                fontColorEnableState: currentTheme?.type == .dark ? UIColor.whiteColor : UIColor.blackColor,
                fontColorNotEnableState: currentTheme?.type == .dark ? UIColor.whiteColor.withAlphaComponent(0.5) : UIColor.blackColor.withAlphaComponent(0.5),
                
                borderColorEnableState: currentTheme?.type == .dark ? UIColor.whiteColor.cgColor : UIColor.whiteColor.cgColor,
                borderColorNotEnableState: currentTheme?.type == .dark ? UIColor.whiteColor.withAlphaComponent(0.5).cgColor : UIColor.whiteColor.withAlphaComponent(0.5).cgColor,
                
                borderWidthEnableState: 1,
                borderWidthDisabledState: 1,
                activityIndicatorColor: UIColor.black
            )
        case .greyStyle(let currentTheme):
            return BaseButtonStylesModel(
                backgroundColorEnableState: currentTheme?.type == .dark ? UIColor.neutralsGray01 : UIColor.neutralsGray06,
                backgroundColorNotEnableState: currentTheme?.type == .dark ? UIColor.neutralsGray01.withAlphaComponent(0.5) : UIColor.neutralsGray06.withAlphaComponent(0.5),
                
                font: .sourceSansProFont(.semiBold, size: 18),
                
                fontColorEnableState: currentTheme?.type == .dark ? UIColor.white : UIColor.black,
                fontColorNotEnableState: UIColor.black,
                
                borderColorEnableState: nil,
                borderColorNotEnableState: nil,
                
                borderWidthEnableState: 0,
                borderWidthDisabledState: 0,
                activityIndicatorColor: UIColor.black
            )
        }
    }
}
