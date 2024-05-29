// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

enum SourceSerifProFont: String {
    case extraLight = "SourceSerifPro-ExtraLight"            // 200
    case extraLightIt = "SourceSerifPro-ExtraLightIt"        // 200
    case light = "SourceSerifPro-Light"                      // 300
    case lightIt = "SourceSerifPro-LightIt"                  // 300
    case regular = "SourceSerifPro-Regular"                  // 400
    case regularItalic = "SourceSerifPro-It"                 // 400
    case semiBold = "SourceSerifPro-Semibold"                // 600
    case semiBoldIt = "SourceSerifPro-SemiboldIt"            // 600
    case bold = "SourceSerifPro-Bold"                        // 700
    case boldIt = "SourceSerifPro-BoldIt"                    // 700
    case black = "SourceSerifPro-Black"                      // 900
    case blackIt = "SourceSerifPro-BlackIt"                  // 900
}

enum SourceSansProFont: String {
    case extraLight = "SourceSansPro-ExtraLight"              // 200
    case extraLightItalic = "SourceSansPro-ExtraLightItalic"  // 200
    case light = "SourceSansPro-Light"                        // 300
    case lightItalic = "SourceSansPro-LightItalic"            // 300
    case regular = "SourceSansPro-Regular"                    // 400
    case regularItalic = "SourceSansPro-Italic"               // 400
    case semiBold = "SourceSansPro-SemiBold"                  // 600
    case semiBoldItalic = "SourceSansPro-SemiBoldItalic"      // 600
    case bold = "SourceSansPro-Bold"                          // 700
    case boldItalic = "SourceSansPro-BoldItalic"              // 700
    case black = "SourceSansPro-Black"                        // 900
    case blackItalic = "SourceSansPro-BlackItalic"            // 900
}
extension UIFont {
    class func sourceSerifProFontFont(_ type: SourceSerifProFont, size: CGFloat) -> UIFont {
        return UIFont(name: type.rawValue, size: size) ?? .systemFont(ofSize: size)
    }
    
    class func sourceSansProFont(_ type: SourceSansProFont, size: CGFloat) -> UIFont {
        return UIFont(name: type.rawValue, size: size) ?? .systemFont(ofSize: size)
    }
}

extension UIFont {
    func withTraits(traits: UIFontDescriptor.SymbolicTraits...) -> UIFont? {
        guard let descriptorL = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits)) else {
            return nil
        }
        return UIFont(descriptor: descriptorL, size: 0)
    }
    func boldItalic() -> UIFont? {
        return withTraits(traits: .traitBold, .traitItalic)
    }
}
