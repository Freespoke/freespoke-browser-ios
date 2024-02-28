// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import OneSignal

class OnboardingEnableNotificationsVC: OnboardingBaseViewController {
    private var contentView: OnboardingContrentView!
    
    private lazy var btnNext: BaseButton = {
        let btn = BaseButton(style: .greenStyle(currentTheme: self.currentTheme))
        btn.setTitle("Next", for: .normal)
        btn.height = 56
        return btn
    }()
    
    private var btnNoThanks: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.sourceSansProFont(.regular, size: 16)
        btn.setTitleColor(UIColor.blackColor, for: .normal)
        btn.setTitle("No thanks to notifications", for: .normal)
        return btn
    }()
    
    override init(currentTheme: Theme?) {
        super.init(currentTheme: currentTheme)
        
        self.contentView = OnboardingContrentView(currentTheme: self.currentTheme)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.addingViews()
        self.setupConstraints()
        self.setupActions()
    }
    
    private func setupUI() {
        self.bottomButtonsView.configure(currentTheme: self.currentTheme)
        self.contentView.configure(currentTheme: self.currentTheme,
                                   lblTitleText: "Stay up to date with the latest.",
                                   lblSubtitleText: "Enable notifications from Freespoke",
                                   imageLight: UIImage(named: "img_enable_notification_popover_light"),
                                   imageDark: UIImage(named: "img_enable_notification_popover_dark"))
        
        self.applyTheme()
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            switch theme.type {
            case .dark:
                self.btnNoThanks.setTitleColor(UIColor.white, for: .normal)
            case .light:
                self.btnNoThanks.setTitleColor(UIColor.blackColor, for: .normal)
            }
        }
    }
    
    private func addingViews() {
        self.view.addSubview(self.contentView)
        
        self.bottomButtonsView.addViews(views: [self.btnNext,
                                                self.btnNoThanks])
        self.addBottomButtonsView()
    }
    
    private func setupConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.btnNoThanks.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.btnNoThanks.heightAnchor.constraint(equalToConstant: 30),
            
            self.contentView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 60),
            self.contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.contentView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomButtonsView.topAnchor, constant: -10)
        ])
    }
}

extension OnboardingEnableNotificationsVC {
    private func setupActions() {
        self.addOnboardingCloseAction()
        
        self.btnNext.addTarget(self,
                               action: #selector(self.btnNextTapped(_:)),
                               for: .touchUpInside)
        
        self.btnNoThanks.addTarget(self,
                                   action: #selector(self.btnNoThanksTapped(_:)),
                                   for: .touchUpInside)
    }
    
    @objc private func btnNextTapped(_ sender: UIButton) {
        // Ask for setup notification setting
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notification: \(accepted)")
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            let vc = OnboardingFinishViewController(currentTheme: self.currentTheme)
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    @objc private func btnNoThanksTapped(_ sender: UIButton) {
        let vc = OnboardingFinishViewController(currentTheme: self.currentTheme)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
