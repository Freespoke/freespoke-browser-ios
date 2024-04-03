// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import MatomoTracker

class OnboardingWelcomeScreen: OnboardingBaseViewController {
    private var topContentView: OnboardingWelcomeScreenContentView!
    
    private lazy var btnContinueWithoutAccount: BaseButton = {
        let btn = BaseButton(style: .greenStyle(currentTheme: self.themeManager.currentTheme))
        btn.setTitle("Continue without account", for: .normal)
        btn.height = 56
        return btn
    }()
    
    private lazy var btnCreateAccount: BaseButton = {
        let btn = BaseButton(style: .greenStyle(currentTheme: self.themeManager.currentTheme))
        btn.setTitle("Create Account", for: .normal)
        btn.height = 56
        return btn
    }()
    
    private var btnLogin = LabelWithUnderlinedButtonView()
    
    lazy var profile: Profile = BrowserProfile(
        localName: "profile",
        syncDelegate: UIApplication.shared.syncDelegate
    )
    
    init() {
        super.init()
        
        self.topContentView = OnboardingWelcomeScreenContentView()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    
    override func applyTheme() {
        super.applyTheme()
        self.topContentView.applyTheme(currentTheme: self.themeManager.currentTheme)
        self.bottomButtonsView.applyTheme(currentTheme: self.themeManager.currentTheme)
        self.btnLogin.applyTheme(currentTheme: self.themeManager.currentTheme)
    }
    
    private func setupUI() {
        self.topContentView.configure(lblTitleText: "Break free from big tech.",
                                      lblSubtitleText: "Get the unfiltered truth.",
                                      lblSecondSubtitleText: "Protect your privacy.")
        
        self.btnLogin.configure(lblTitleText: "Already have an account?",
                                btnTitleText: "Log In")
    }
    
    private func addingViews() {
        self.view.addSubview(self.topContentView)
        
        self.bottomButtonsView.addViews(views: [self.btnContinueWithoutAccount,
                                                self.btnCreateAccount,
                                                self.btnLogin])
        self.addBottomButtonsView()
    }
    
    private func setupConstraints() {
        self.topContentView.translatesAutoresizingMaskIntoConstraints = false
        self.btnContinueWithoutAccount.translatesAutoresizingMaskIntoConstraints = false
        self.btnCreateAccount.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: constraints are set depending on the type of device iPad or iPhone
        if UIDevice.current.isPad {
            NSLayoutConstraint.activate([
                self.topContentView.topAnchor.constraint(equalTo: self.btnClose.bottomAnchor, constant: 15),
                self.topContentView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 0),
                self.topContentView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: 0),
                self.topContentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.topContentView.widthAnchor.constraint(equalToConstant: (self.view.frame.width * Constants.DrawingSizes.iPadContentWidthFactorPortrait)),
            ])
        } else {
            NSLayoutConstraint.activate([
                self.topContentView.topAnchor.constraint(equalTo: self.btnClose.bottomAnchor, constant: 5),
                self.topContentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.topContentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        }
    }
}

extension OnboardingWelcomeScreen {
    private func setupActions() {
        self.addOnboardingCloseAction()
        
        self.btnContinueWithoutAccount.addTarget(self,
                                                 action: #selector(self.btnContinueWithoutAccountTapped(_:)),
                                                 for: .touchUpInside)
        
        self.btnCreateAccount.addTarget(self,
                                        action: #selector(self.btnCreateAccountTapped(_:)),
                                        for: .touchUpInside)
        
        self.btnLogin.tapClosure = { [weak self] in
            guard let self = self else { return }
            self.performFreespokeLoginAction()
        }
    }
    
    private func performFreespokeLoginAction() {
        AppSessionManager.shared.performFreespokeLogin(parentVC: self, successCompletion: { [weak self] authModel in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.onboardingCloseAction(animated: false)
            })
        })
    }
    
    @objc private func btnContinueWithoutAccountTapped(_ sender: UIButton) {
        MatomoTracker.shared.track(eventWithCategory: MatomoCategory.appOnboardCategory.rawValue,
                                   action: MatomoAction.appOnbWithoutAccClickAction.rawValue,
                                   name: MatomoName.clickName.rawValue,
                                   value: nil)
        
        let vc = OnboardingSetDefaultBrowserVC(source: .continueWithoutAccount)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func btnCreateAccountTapped(_ sender: UIButton) {
        MatomoTracker.shared.track(eventWithCategory: MatomoCategory.appOnboardCategory.rawValue,
                                   action: MatomoAction.appOnbCreateAccClickAction.rawValue,
                                   name: MatomoName.clickName.rawValue,
                                   value: nil)
        let vc = SignUpVC(viewModel: SignUpVCViewModel(isOnboarding: true))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
