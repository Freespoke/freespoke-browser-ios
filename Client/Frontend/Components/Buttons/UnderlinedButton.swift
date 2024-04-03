// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class UnderlinedButton: UIButton {
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        self.underline(text: title)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .curveLinear,
                           animations: { [weak self] in
                self?.alpha = 0.75
                self?.titleLabel?.alpha = 0.5
            }, completion: nil)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: { [weak self] in
                self?.alpha = 1
                self?.titleLabel?.alpha = 1
            })
        }
    }
    
    private func underline(text: String?) {
        guard let text = text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0,
                                                     length: text.count))
        
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
