// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

enum SourceSansProFont: String {
    case regular = "SourceSansPro-Regular"
    case semiBold = "SourceSansPro-SemiBold"
    case bold = "SourceSansPro-Bold"
}

extension UIFont {
    class func sourceSansProFont(_ type: SourceSansProFont, size: CGFloat) -> UIFont {
        return UIFont(name: type.rawValue, size: size) ?? .systemFont(ofSize: size)
    }
}

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont? {
        guard let descriptorL = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits)) else{
            return nil
        }
        return UIFont(descriptor: descriptorL, size: 0)
    }
    func boldItalic() -> UIFont? {
        return withTraits(traits: .traitBold, .traitItalic)
    }
}
