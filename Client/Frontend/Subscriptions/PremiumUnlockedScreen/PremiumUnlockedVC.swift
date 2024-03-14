// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class PremiumUnlockedVC: OnboardingBaseViewController {
    private var topContentView: PremiumUnlockedContentView!
    
    private lazy var btnNext: BaseButton = {
        let btn = BaseButton(style: .greenStyle(currentTheme: self.currentTheme))
        btn.setTitle("Next", for: .normal)
        btn.height = 56
        return btn
    }()
    
    let isOnboarding: Bool
    
    init(currentTheme: Theme?, isOnboarding: Bool) {
        self.isOnboarding = isOnboarding
        super.init(currentTheme: currentTheme)
        self.topContentView = PremiumUnlockedContentView(currentTheme: self.currentTheme)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupUI() {
        self.topContentView.configure(currentTheme: self.currentTheme,
                                      lblTitleText: "Success! You’ve Unlocked Freespoke Premium.",
                                      lblSubtitleText: "Enjoy ad-free search and unbiased news.",
                                      lblSecondSubtitleText: "This badge shows when Premium is active.")
        
        self.bottomButtonsView.configure(currentTheme: self.currentTheme)
    }
    
    private func addingViews() {
        self.view.addSubview(self.topContentView)
        
        self.bottomButtonsView.addViews(views: [self.btnNext])
        self.addBottomButtonsView()
    }
    
    private func setupConstraints() {
        self.topContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//            self.topContentView.topAnchor.constraint(equalTo: self.btnClose.bottomAnchor, constant: UIDevice.current.isPad ? 15 : 0),
            self.topContentView.topAnchor.constraint(equalTo: self.btnClose.bottomAnchor, constant: 0),
            self.topContentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topContentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
}

extension PremiumUnlockedVC {
    private func setupActions() {
        if isOnboarding {
            self.addOnboardingCloseAction()
            self.btnNext.addTarget(self,
                                   action: #selector(self.btnNextOnboardingTapped(_:)),
                                   for: .touchUpInside)
        } else {
            self.btnClose.addTarget(self,
                                    action: #selector(self.btnNextNotOnbordingTapped(_:)),
                                    for: .touchUpInside)
            self.btnNext.addTarget(self,
                                   action: #selector(self.btnNextNotOnbordingTapped(_:)),
                                   for: .touchUpInside)
        }
    }
    
    @objc private func btnNextOnboardingTapped(_ sender: UIButton) {
        let vc = OnboardingSetDefaultBrowserVC(currentTheme: self.currentTheme)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func btnNextNotOnbordingTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
