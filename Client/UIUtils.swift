// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

enum UIUtils {
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
    
    static func showTwoButtonsAlertInNewWindow(title: String?, message: String?, titleForFirstButton: String = "OK", titleForSecondButton: String, firstCompletion: (() -> Void)? = nil, secondCompletion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = DBAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            
            let firstButtonAction = UIAlertAction(title: titleForFirstButton,
                                                  style: .default,
                                                  handler: { _ in
                firstCompletion?()
            })
            
            let secondButtonAction = UIAlertAction(title: titleForSecondButton,
                                                   style: .default,
                                                   handler: { _ in
                secondCompletion?()
            })
            
            alert.addAction(secondButtonAction)
            alert.addAction(firstButtonAction)
            
            alert.show()
        }
    }
    
    // MARK: - display Open Settings Alert and navigate to general settings
    
    static func displayOpenSettingsAlert(title: String, message: String, btnOpenSettingsTitle: String, openSettingsButtonCompletion: (() -> Void)?, cancelButtonCompletion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .cancel,
                                             handler: { _ in
                cancelButtonCompletion?()
            })
            
            cancelAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            alert.addAction(cancelAction)
            
            let openSettingsAction = UIAlertAction(title: btnOpenSettingsTitle,
                                                   style: UIAlertAction.Style.default,
                                                   handler: { _ in
                guard let appBundleIdentifier = Bundle.main.bundleIdentifier,
                      let url = URL(string: UIApplication.openSettingsURLString + appBundleIdentifier),
                      UIApplication.shared.canOpenURL(url) else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                openSettingsButtonCompletion?()
            })
            
            openSettingsAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            alert.addAction(openSettingsAction)
            
            guard let topMostVC = UIApplication
                .shared
                .keyWindowPresentedController(includingTabBar: false) else { return }
            topMostVC.present(alert, animated: true, completion: nil)
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

