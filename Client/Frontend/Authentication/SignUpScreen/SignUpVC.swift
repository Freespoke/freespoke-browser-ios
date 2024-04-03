// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class SignUpVC: OnboardingBaseViewController {
    private let viewModel: SignUpVCViewModel
    
    private let scrollView = UIScrollView()
    private var scrollableContentView: SignUpContentView!
    
    private lazy var btnNext: BaseButton = {
        let btn = BaseButton(style: .greenStyle(currentTheme: self.themeManager.currentTheme))
        btn.setTitle("Next", for: .normal)
        btn.height = 56
        btn.isEnabled = false
        return btn
    }()
    
    private var btnLogin = LabelWithUnderlinedButtonView()
    
    init(viewModel: SignUpVCViewModel) {
        self.viewModel = viewModel
        super.init()
        
        self.scrollableContentView = SignUpContentView()
        self.scrollableContentView.delegate = self
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
        self.hideKeyboardWhenTappedAround()
        
        self.listenForThemeChange(self.view)
        self.applyTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateScrollViewBottomContentInset(to: self.bottomButtonsView.frame.height)
    }
    
    override func applyTheme() {
        super.applyTheme()
        
        self.scrollableContentView.applyTheme(currentTheme: self.themeManager.currentTheme)
        self.btnLogin.applyTheme(currentTheme: self.themeManager.currentTheme)
        self.bottomButtonsView.applyTheme(currentTheme: self.themeManager.currentTheme)
    }
    
    private func setupUI() {
        self.scrollableContentView.configure(lblTitleText: "Join the Freespoke \n revolution!",
                                             lblSubtitleText: "Take back control from big tech.")
        
        self.setupBottomButtonsView()
        
        self.btnLogin.configure(lblTitleText: "Already have an account?",
                                btnTitleText: "Log In")
    }
    
    private func addingViews() {
        self.addScrollView()
        self.addScrollableContentView()
        self.addBottomButtonsView()
    }
    
    private func setupConstraints() {
        self.addScrollViewConstraints()
        self.addScrollableContentViewConstraints()
    }
}

// MARK: - Add Scroll View

extension SignUpVC {
    private func addScrollView() {
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.bounces = false
        self.view.addSubview(self.scrollView)
    }
    
    private func addScrollViewConstraints() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

// MARK: - Add Scrollable Content View

extension SignUpVC {
    private func addScrollableContentView() {
        self.scrollView.addSubview(self.scrollableContentView)
    }
    
    private func addScrollableContentViewConstraints() {
        self.scrollableContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.scrollableContentView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.scrollableContentView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.scrollableContentView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.scrollableContentView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.scrollableContentView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func updateScrollViewBottomContentInset(to bottomInset: CGFloat) {
        self.scrollView.contentInset.bottom = bottomInset
    }
}

// MARK: - Add Bottom Buttons View

extension SignUpVC {
    private func setupBottomButtonsView() {
        self.btnLogin.configure(lblTitleText: "Already have an account?",
                                btnTitleText: "Log In")
        
        self.bottomButtonsView.addViews(views: [self.btnNext,
                                                self.btnLogin])
    }
}

// MARK: - Setup Actions

extension SignUpVC {
    private func setupActions() {
        if self.viewModel.isOnboarding {
            self.addOnboardingCloseAction()
        } else {
            self.btnClose.addTarget(self,
                                    action: #selector(self.btnCloseNotOnboardingAction),
                                    for: .touchUpInside)
        }
        
        self.scrollableContentView.signInWithAppleItem.tapClosure = { [weak self] in
            guard let self = self else { return }
            self.viewModel.authWithApple(completion: { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    print("TEST: SignUpVC self.viewModel.authWithApple error: ", error)
                    self.scrollableContentView.signInWithAppleItem.errorMessage = "Unable to connect with Apple account."
                } else {
                    guard let decodedJWTToken = AppSessionManager.shared.decodedJWTToken else { return }
                    Task {
                        if let subscriptionType = try? await decodedJWTToken.subscriptionType() {
                            switch subscriptionType {
                            case .trialExpired:
                                self.openSubscriptionScreen()
                            case .originalApple, .notApple:
                                if self.viewModel.isOnboarding {
                                    self.onboardingCloseAction(animated: false)
                                } else {
                                    self.btnCloseNotOnboardingAction()
                                }
                            }
                        } else {
                            self.openSubscriptionScreen()
                        }
                    }
                }
            })
        }
        
        self.btnNext.addTarget(self,
                               action: #selector(self.btnNextTapped(_:)),
                               for: .touchUpInside)
        
        self.btnLogin.tapClosure = { [weak self] in
            guard let self = self else { return }
            self.performFreespokeLoginAction()
        }
    }
    
    private func performFreespokeLoginAction() {
        AppSessionManager.shared.performFreespokeLogin(parentVC: self,
                                                       successCompletion: { [weak self] authModel in
            guard let self = self else { return }
            Task {
                if self.viewModel.isOnboarding, let subscriptionType = try? await AppSessionManager.shared.decodedJWTToken?.subscriptionType() {
                    switch subscriptionType {
                    case .trialExpired:
                        self.openSubscriptionScreen()
                    case .originalApple, .notApple:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            self.onboardingCloseAction(animated: false)
                        })
                    }
                } else {
                    self.openSubscriptionScreen()
                }
            }
        })
    }
    
    @objc private func btnCloseNotOnboardingAction() {
        self.motionDismissViewController(animated: true)
    }
    
    @objc private func btnNextTapped(_ sender: UIButton) {
        guard let firstName = self.scrollableContentView.firstNameItem.getText() else { return }
        guard let lastName = self.scrollableContentView.lastNameItem.getText() else { return }
        guard let email = self.scrollableContentView.emailItem.getText() else { return }
        guard let password = self.scrollableContentView.passwordItem.getText() else { return }
        
        self.btnNext.startIndicator()
        self.viewModel.registerUser(firstName: firstName,
                                    lastName: lastName,
                                    email: email,
                                    password: password,
                                    completion: { [weak self] error in
            guard let self = self else { return }
            self.btnNext.stopIndicator()
            if let error = error {
                UIUtils.showOkAlert(title: error.errorName, message: error.errorDescription)
            } else {
                self.openSubscriptionScreen()
            }
        })
    }
}

// MARK: - Navigation

extension SignUpVC {
    private func openSubscriptionScreen() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let vc = SubscriptionsVC(viewModel: SubscriptionsVCViewModel(isOnboarding: self.viewModel.isOnboarding))
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Keyboard & Validation

extension SignUpVC: SignUpContentViewDelegate {
    func keyboardWillShowWithHeight(_ keyboardHeight: CGFloat, notification: NSNotification) {
        let bottomInset = keyboardHeight
        self.updateScrollViewBottomContentInset(to: bottomInset)
        guard let activeTextField = self.scrollableContentView.activeTextField else { return }
        
        var textFieldRect = activeTextField.textField.convert(activeTextField.textField.bounds, to: self.scrollView)
        textFieldRect.size.height += 10
        
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        
        self.scrollView.scrollRectToVisible(textFieldRect, animated: true)
        
        UIView.animate(withDuration: duration?.doubleValue ?? 0.0, delay: 0.0, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue((curve?.intValue)!)), animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide() {
        let bottomInset = self.bottomButtonsView.frame.height
        self.updateScrollViewBottomContentInset(to: bottomInset)
    }
    
    func enteredDataUpdated() {
        // MARK: Validate First Name
        guard let firstName = self.scrollableContentView.firstNameItem.getText(),
              case .valid = Validator.validateFirstName(firstName)
        else {
            self.btnNext.isEnabled = false
            return
        }
        
        // MARK: Validate Last Name
        guard let lastName = self.scrollableContentView.lastNameItem.getText(),
              case .valid = Validator.validateLastName(lastName)
        else {
            self.btnNext.isEnabled = false
            return
        }
        
        // MARK: Validate Email
        guard let email = self.scrollableContentView.emailItem.getText(),
              case .valid = Validator.validateEmail(email)
        else {
            self.btnNext.isEnabled = false
            return
        }
        
        // MARK: Validate Password
        guard let password = self.scrollableContentView.passwordItem.getText(),
              case .valid = Validator.validatePassword(password)
        else {
            self.btnNext.isEnabled = false
            return
        }
        
        self.btnNext.isEnabled = true
    }
}
