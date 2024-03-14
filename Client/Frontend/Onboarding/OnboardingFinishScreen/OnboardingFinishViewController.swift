// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class OnboardingFinishViewController: OnboardingBaseViewController {
    private var contentView: OnboardingContrentView!
    
    private lazy var btnFinish: BaseButton = {
        let btn = BaseButton(style: .greenStyle(currentTheme: self.currentTheme))
        btn.setTitle("Finish", for: .normal)
        btn.height = 56
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
                                   lblTitleText: "Thanks for joining the Freespoke revolution.",
                                   lblSubtitleText: "Give Freespoke a spin. And be sure to tell your friends!",
                                   imageLight: UIImage(named: "img_onboarding_finish_screen_light"),
                                   imageDark: UIImage(named: "img_onboarding_finish_screen_dark"))
    }
    
    private func addingViews() {
        self.view.addSubview(self.contentView)
        
        self.bottomButtonsView.addViews(views: [self.btnFinish])
        self.addBottomButtonsView()
    }
    
    private func setupConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: UIDevice.current.isPad ? 90 : 60),
            self.contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.contentView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomButtonsView.topAnchor, constant: -10)
        ])
    }
}

extension OnboardingFinishViewController {
    private func setupActions() {
        self.addOnboardingCloseAction()
        self.btnFinish.addTarget(self,
                                 action: #selector(self.btnFinishTapped(_:)),
                                 for: .touchUpInside)
    }

    @objc private func btnFinishTapped(_ sender: UIButton) {
        self.onboardingCloseAction()
    }
}
