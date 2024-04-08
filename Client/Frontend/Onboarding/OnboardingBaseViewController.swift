// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Common

class OnboardingBaseViewController: UIViewController, Themeable {
    var btnClose: UIButton = {
        let btn = UIButton()
        btn.layer.zPosition = 10
        return btn
    }()
    
    private var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor
        return view
    }()
    
    let bottomButtonsView = OnboardingBottomButtonsView()
    
    private lazy var profile: Profile = BrowserProfile(
        localName: "profile",
        syncDelegate: UIApplication.shared.syncDelegate
    )
    
    var themeManager: ThemeManager
    var notificationCenter: NotificationProtocol
    var themeObserver: NSObjectProtocol?
    
    init(themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default) {
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCloseButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.bringSubviewToFront(self.btnClose)
    }
    
    func applyTheme() {
        self.bottomButtonsView.applyTheme(currentTheme: self.themeManager.currentTheme)
        
        switch self.themeManager.currentTheme.type {
        case .dark:
            self.view.backgroundColor = UIColor.black
            let closeImage = UIImage(named: "img_close_onboarding")?.withTintColor(.whiteColor, renderingMode: .alwaysOriginal)
            self.btnClose.setImage(closeImage, for: .normal)
            self.lineView.backgroundColor = UIColor.blackColor
        case .light:
            self.view.backgroundColor = UIColor.gray7
            let closeImage = UIImage(named: "img_close_onboarding")?.withTintColor(.blackColor, renderingMode: .alwaysOriginal)
            self.btnClose.setImage(closeImage, for: .normal)
            self.lineView.backgroundColor = UIColor.whiteColor
        }
    }
    
    private func addCloseButton() {
        self.view.addSubview(self.btnClose)
        self.addCloseButtonConstraints()
    }
    
    func addBottomButtonsView() {
        self.view.addSubview(self.bottomButtonsView)
        self.view.addSubview(self.lineView)
        self.addBottomButtonsViewConstraints()
        self.addLineViewConstraints()
    }
    
    private func addCloseButtonConstraints() {
        self.btnClose.translatesAutoresizingMaskIntoConstraints = false
        
        if UIDevice.current.isPad {
            NSLayoutConstraint.activate([
                self.btnClose.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.btnClose.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
            ])
        }
        
        NSLayoutConstraint.activate([
            self.btnClose.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            self.btnClose.heightAnchor.constraint(equalToConstant: 52),
            self.btnClose.widthAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    private func addLineViewConstraints() {
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.lineView.topAnchor.constraint(equalTo: self.bottomButtonsView.topAnchor, constant: 0),
            self.lineView.heightAnchor.constraint(equalToConstant: 1),
            self.lineView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.lineView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    private func addBottomButtonsViewConstraints() {
        self.bottomButtonsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.bottomButtonsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomButtonsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomButtonsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

extension OnboardingBaseViewController {
    func addOnboardingCloseAction() {
        self.btnClose.addTarget(self,
                                action: #selector(self.onboardingCloseAction),
                                for: .touchUpInside)
    }
    
    @objc func onboardingCloseAction(animated: Bool = true) {
        AnalyticsManager.trackMatomoEvent(category: .appOnboardCategory,
                                          action: AnalyticsManager.MatomoAction.appOnbCloseClickAction.rawValue,
                                          name: AnalyticsManager.MatomoName.clickName)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.profile.prefs.setInt(1, forKey: PrefsKeys.IntroSeen)
            OrientationLockUtility.lockOrientation(UIInterfaceOrientationMask.all)
            self.navigationController?.dismiss(animated: true)
        }
    }
}
