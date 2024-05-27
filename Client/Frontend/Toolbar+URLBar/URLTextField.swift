// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class URLTextField: UITextField {
    // MARK: UX
    struct UX {
        static let defSpacing: CGFloat = 8
        static let zeroSpacing: CGFloat = 0
    }

    weak var accessibilityActionsSource: AccessibilityActionsSource?

    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            return accessibilityActionsSource?.accessibilityCustomActionsForView(self)
        }
        set {
            super.accessibilityCustomActions = newValue
        }
    }

    override var canBecomeFirstResponder: Bool {
        return false
    }

    private var isSpecialRect: Bool = false
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        switch self.isSpecialRect {
        case true:
            return bounds.insetBy(dx: UX.defSpacing, dy: 0)
        case false:
            return bounds.insetBy(dx: UX.zeroSpacing, dy: 0)
        }
    }
    
    func updateTextRect(isSpecial: Bool) {
         isSpecialRect = isSpecial
         setNeedsDisplay()
     }
    
    override var intrinsicContentSize: CGSize {
        let parentSize = super.intrinsicContentSize
        //calculate min size, to prevent  changing width of field lower than this
        var minSize = (String(repeating: "0", count: 1) as NSString).size(withAttributes: [NSAttributedString.Key.font: font as Any])
        minSize.height = parentSize.height
        
        if isEditing {
            if let text = text,
               !text.isEmpty {
                // Convert to NSString to use size(attributes:)
                let string = text as NSString
                // Calculate size for current text
                var returnSize = string.size(withAttributes: typingAttributes)
                // Add margin to calculated size
                returnSize.width += 10
                returnSize.height = parentSize.height
                return returnSize.width >  minSize.width ? returnSize : minSize
            } else {
                // You can return some custom size in case of empty string
                return parentSize
            }
        } else {
            if let text = text,
               !text.isEmpty {
                var returnSize = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font as Any] )
                returnSize.width += 10
                returnSize.height = parentSize.height
                return returnSize.width >  minSize.width ?  returnSize :  minSize
            }
            return parentSize
        }
    }
}

