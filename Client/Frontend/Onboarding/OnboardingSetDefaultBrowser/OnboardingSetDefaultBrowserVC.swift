// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

enum OnboardingSourceDestination {
    case continueWithoutAccount
    case createAccount
}

class OnboardingSetDefaultBrowserVC: OnboardingBaseViewController {
    private var contentView: OnboardingContrentView!
    
    private lazy var btnSetAsDefaultBrowser: MainButton = {
        let btn = MainButton()
        btn.setTitle("Set as default browser", for: .normal)
        return btn
    }()
    
    private var btnNoThanks: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.sourceSansProFont(.regular, size: 16)
        btn.setTitleColor(UIColor.blackColor, for: .normal)
        btn.setTitle("No thanks, I’ll stick with Big Tech", for: .normal)
        return btn
    }()
    
    private let source: OnboardingSourceDestination
    
    init(source: OnboardingSourceDestination) {
        self.source = source
        super.init()
        
        self.contentView = OnboardingContrentView()
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
        
        self.listenForThemeChange(self.view)
        self.applyTheme()
    }
    
    private func setupUI() {
        self.contentView.configure(lblTitleText: "Make Freespoke \n your favorite.",
                                   lblSubtitleText: "Set Freespoke as your default browser and break free from big tech.",
                                   imageLight: UIImage(named: "img_set_as_default_browser_light"),
                                   imageDark: UIImage(named: "img_set_as_default_browser_dark"))
        
        self.applyTheme()
    }
    
    override func applyTheme() {
        super.applyTheme()
        
        self.btnSetAsDefaultBrowser.applyTheme()
        self.contentView.applyTheme(currentTheme: self.themeManager.currentTheme)
        
        switch self.themeManager.currentTheme.type {
        case .dark:
            self.btnNoThanks.setTitleColor(UIColor.white, for: .normal)
        case .light:
            self.btnNoThanks.setTitleColor(UIColor.blackColor, for: .normal)
        }
    }
    
    private func addingViews() {
        self.view.addSubview(self.contentView)
        
        self.bottomButtonsView.addViews(views: [self.btnSetAsDefaultBrowser,
                                                self.btnNoThanks])
        self.addBottomButtonsView()
    }
    
    private func setupConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.btnNoThanks.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.btnNoThanks.heightAnchor.constraint(equalToConstant: 30),
            
            self.contentView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: UIDevice.current.isPad ? 90 : 60),
            self.contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.contentView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomButtonsView.topAnchor, constant: -10)
        ])
    }
}

extension OnboardingSetDefaultBrowserVC {
    private func setupActions() {
        self.addOnboardingCloseAction()
        
        self.btnSetAsDefaultBrowser.addTarget(self,
                                              action: #selector(self.btnSetAsDefaultBrowserTapped(_:)),
                                              for: .touchUpInside)
        
        self.btnNoThanks.addTarget(self,
                                   action: #selector(self.btnNoThanksTapped(_:)),
                                   for: .touchUpInside)
    }
    
    @objc private func btnSetAsDefaultBrowserTapped(_ sender: UIButton) {
        switch self.source {
        case .continueWithoutAccount:
            AnalyticsManager.trackMatomoEvent(category: .appOnboardCategory,
                                              action: AnalyticsManager.MatomoAction.appOnbWithoutAccSetAsDefBrowserClickAction.rawValue,
                                              name: AnalyticsManager.MatomoName.clickName)
        case .createAccount:
            AnalyticsManager.trackMatomoEvent(category: .appOnboardCategory,
                                              action: AnalyticsManager.MatomoAction.appOnbCreateAccSetAsDefBrowserClickAction.rawValue,
                                              name: AnalyticsManager.MatomoName.clickName)
        }
        
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            let vc = OnboardingEnableNotificationsVC(source: self.source)
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    @objc private func btnNoThanksTapped(_ sender: UIButton) {
        let vc = OnboardingEnableNotificationsVC(source: self.source)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
