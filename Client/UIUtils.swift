// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

enum UIUtils {
    static func showOkAlert(title: String, message: String?, titleForButton: String = "OK", buttonTintColor: UIColor? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            guard let topMostVC = UIApplication.shared.keyWindowPresentedController() else { return }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let buttonAction = UIAlertAction(title: titleForButton, 
                                             style: UIAlertAction.Style.cancel,
                                             handler: { _ in
                completion?()
            })
            
            alert.addAction(buttonAction)
            
            if let tint = buttonTintColor {
                buttonAction.setValue(tint, forKey: "titleTextColor")
            } else {
                buttonAction.setValue(UIColor.greenColor, forKey: "titleTextColor")
            }
            
            topMostVC.present(alert, animated: true)
        }
    }
    
    static func showOkAlertInNewWindow(title: String?, message: String?, titleForButton: String = "OK", completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = DBAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: titleForButton,
                                             style: UIAlertAction.Style.cancel,
                                             handler: { _ in
                completion?()
            })
            
            alert.addAction(cancelAction)
            alert.show()
        }
    }
}

// MARK: - DBAlertController

/// The UIWindow that will be at the top of the window hierarchy. The DBAlertController instance is presented on the rootViewController of this window.
public class DBAlertController: UIAlertController {
    private lazy var alertWindow: UIWindow = {
        if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = UIWindow(windowScene: currentWindowScene)
            window.rootViewController = DBClearViewController()
            window.backgroundColor = UIColor.clear
            window.windowLevel = UIWindow.Level.alert
            return window
        }
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = DBClearViewController()
        window.backgroundColor = UIColor.clear
        window.windowLevel = UIWindow.Level.alert
        return window
    }()
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.alertWindow.isHidden = true
    }
    
    /**
     Present the DBAlertController on top of the visible UIViewController.
     
     - parameter flag:       Pass true to animate the presentation; otherwise, pass false. The presentation is animated by default.
     - parameter completion: The closure to execute after the presentation finishes.
     - parameter sourceRect: The bounds of action button - in UIWindow coordinate system
     */
    public func show(animated flag: Bool = true,
                     sourceRect: CGRect? = nil,
                     completion: (() -> Void)? = nil) {
        self.view.tintColor = .white
        self.overrideUserInterfaceStyle = .dark
        
        if let rootViewController = alertWindow.rootViewController {
            alertWindow.makeKeyAndVisible()
            
            self.popoverPresentationController?.sourceView = rootViewController.view
            self.popoverPresentationController?.sourceRect = sourceRect ??
            CGRect(x: rootViewController.view.bounds.midX,
                   y: rootViewController.view.bounds.midY,
                   width: 2,
                   height: 2)
            
            if sourceRect == nil {
                self.popoverPresentationController?.permittedArrowDirections = []
            }
            
            rootViewController.present(self, animated: flag, completion: completion)
        }
    }
}

// In the case of view controller-based status bar style, make sure we use the same style for our view controller
private class DBClearViewController: UIViewController { }

