// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

extension UIView {
    func pinToView(view: UIView, safeAreaLayout: Bool = false, withInsets insets: UIEdgeInsets? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if safeAreaLayout {
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                              constant: insets?.left ?? 0),
                self.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                               constant: -(insets?.right ?? 0)),
                self.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                          constant: insets?.top ?? 0),
                self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                             constant: -(insets?.bottom ?? 0))
            ])
        } else {
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets?.left ?? 0),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(insets?.right ?? 0)),
                self.topAnchor.constraint(equalTo: view.topAnchor, constant: insets?.top ?? 0),
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(insets?.bottom ?? 0))
            ])
        }
    }
    
    func pinToView(view: UIView, withInsets insets: UIEdgeInsets) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ])
    }
    
    /** Get the Parent View Controller */
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
