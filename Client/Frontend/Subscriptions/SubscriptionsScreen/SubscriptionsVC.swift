// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import StoreKit
import Combine

class SubscriptionsVC: OnboardingBaseViewController {
    private let viewModel: SubscriptionsVCViewModel
    private let scrollView = UIScrollView()
    private var scrollableContentView: SubscriptionsContentView!
    
    private var activityIndicator = BaseActivityIndicator(activityIndicatorSize: .large)
    
    // MARK: Bottom buttons view
    
    private var lblDescription: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = UIColor.blackColor
        lbl.font = UIFont.sourceSansProFont(.regular, size: 13)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    
    private lazy var btnMonthlySubscription: MainButton = {
        let btn = MainButton()
        return btn
    }()
    
    private lazy var btnYearlySubscription: MainButton = {
        let btn = MainButton()
        return btn
    }()
    
    private lazy var btnUpdateSubscription: MainButton = {
        let btn = MainButton()
        return btn
    }()
    
    private lazy var btnCancelSubscription: SecondaryButton = {
        let btn = SecondaryButton()
        return btn
    }()
    
    private var btnRestorePurchases = LabelWithUnderlinedButtonView()
    
    private let btnContinue: UnderlinedButton = {
        let btn = UnderlinedButton()
        btn.titleLabel?.font = UIFont.sourceSansProFont(.regular, size: 16)
        btn.setTitleColor(UIColor.blackColor, for: .normal)
        return btn
    }()
    
    private var stateSubscription: AnyCancellable?
    
    init(viewModel: SubscriptionsVCViewModel) {
        self.viewModel = viewModel
        super.init()
        self.viewModel.delegate = self
        self.scrollableContentView = SubscriptionsContentView()
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
        self.subscribeToViewModelStatePublisher()
        
        self.listenForThemeChange(self.view)
        self.applyTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.viewControllers.removeAll(where: { $0 is SignUpVC })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.contentInset.bottom = self.bottomButtonsView.frame.height
    }
    
    private func subscribeToViewModelStatePublisher() {
        self.stateSubscription = self.viewModel.$subscriptionType
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.setupUI()
            }
    }
    
    private func setupUI() {
        self.scrollableContentView.configure(lblTitleText: self.viewModel.titleText,
                                             lblSubtitleText: self.viewModel.subtitleText)
        
        self.setupBottomButtonsView()
        
        self.btnRestorePurchases.tapClosure = { [weak self] in
            self?.showActivityIndicatorOverFullScreen()
            self?.viewModel.restorePurchases(completion: { [weak self] status in
                guard let self = self else { return }
                self.removeActivityIndicatorFromScreen()
            })
        }
    }
    
    private func showActivityIndicatorOverFullScreen() {
        guard let window = self.view.window else { return }
        guard self.activityIndicator.superview == nil else { return }
        self.activityIndicator.start(pinToView: window, overlayMode: .standart)
    }
    
    private func removeActivityIndicatorFromScreen() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.removeFromSuperview()
        }
    }
    
    override func applyTheme() {
        super.applyTheme()
        
        self.btnRestorePurchases.applyTheme(currentTheme: self.themeManager.currentTheme)
        
        self.btnMonthlySubscription.applyTheme()
        self.btnYearlySubscription.applyTheme()
        self.btnUpdateSubscription.applyTheme()
        self.btnCancelSubscription.applyTheme()
        
        self.scrollableContentView.applyTheme(currentTheme: self.themeManager.currentTheme)
        self.activityIndicator.applyTheme(currentTheme: self.themeManager.currentTheme)
        
        switch self.themeManager.currentTheme.type {
        case .dark:
            self.lblDescription.textColor = UIColor.lightGray
            self.btnContinue.setTitleColor(UIColor.whiteColor, for: .normal)
            
        case .light:
            self.lblDescription.textColor = UIColor.blackColor
            self.btnContinue.setTitleColor(UIColor.blackColor, for: .normal)
        }
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

// MARK: - Setup Actions

extension SubscriptionsVC {
    private func setupActions() {
        self.btnMonthlySubscription.addTarget(self,
                                              action: #selector(self.btnMonthlySubscriptionTapped(_:)),
                                              for: .touchUpInside)
        
        self.btnYearlySubscription.addTarget(self,
                                             action: #selector(self.btnYearlySubscriptionTapped(_:)),
                                             for: .touchUpInside)
        
        self.btnUpdateSubscription.addTarget(self,
                                             action: #selector(self.btnUpdateSubscriptionTapped(_:)),
                                             for: .touchUpInside)
        
        self.btnCancelSubscription.addTarget(self,
                                             action: #selector(self.btnCancelSubscriptionTapped(_:)),
                                             for: .touchUpInside)
        
        self.btnContinue.addTarget(self,
                                   action: #selector(self.btnContinueTapped(_:)),
                                   for: .touchUpInside)
        
        if self.viewModel.isOnboarding {
            self.addOnboardingCloseAction()
        } else {
            self.btnClose.addTarget(self,
                                    action: #selector(self.btnCloseNotOnboardingAction(_:)),
                                    for: .touchUpInside)
        }
    }
    
    @objc private func btnMonthlySubscriptionTapped(_ sender: UIButton) {
        AnalyticsManager.trackMatomoEvent(category: .appOnboardCategory,
                                          action: AnalyticsManager.MatomoAction.appOnbCreateAccPremiumPriceClickAction.rawValue,
                                          name: AnalyticsManager.MatomoName.clickName)
        self.btnMonthlySubscription.startIndicator()
        self.btnYearlySubscription.isEnabled = false
        self.viewModel.purchaseMonthlySubscription(completion: { [weak self] status in
            guard let self = self else { return }
            self.btnMonthlySubscription.stopIndicator()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.btnYearlySubscription.isEnabled = true
            }
        })
    }
    
    @objc private func btnYearlySubscriptionTapped(_ sender: UIButton) {
        AnalyticsManager.trackMatomoEvent(category: .appOnboardCategory,
                                          action: AnalyticsManager.MatomoAction.appOnbCreateAccPremiumPriceClickAction.rawValue,
                                          name: AnalyticsManager.MatomoName.clickName)
        self.btnYearlySubscription.startIndicator()
        self.btnMonthlySubscription.isEnabled = false
        self.viewModel.purchaseYearlySubscription(completion: { [weak self] status in
            guard let self = self else { return }
            self.btnYearlySubscription.stopIndicator()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.btnMonthlySubscription.isEnabled = true
            }
        })
    }
    
    @objc private func btnUpdateSubscriptionTapped(_ sender: UIButton) {
        AnalyticsManager.trackMatomoEvent(category: .appMenuCategory,
                                          action: AnalyticsManager.MatomoAction.appManageUpdatePlanClickAction.rawValue,
                                          name: AnalyticsManager.MatomoName.clickName)
        
        let subscriptionSource = AppSessionManager.shared.decodedJWTToken?.subscription?.subscriptionSource
        
        switch subscriptionSource {
        case .ios:
            if let appStoreSubscriptionURL = URL(string: Constants.appleNativeSubscriptions.rawValue) {
                UIApplication.shared.open(appStoreSubscriptionURL, options: [:], completionHandler: nil)
            }
        default:
            self.btnUpdateSubscription.startIndicator()
            self.performUpdateCancelSubscriptionAction(completion: { [weak self] in
                guard let self = self else { return }
                self.btnUpdateSubscription.stopIndicator()
            })
        }
    }
    
    @objc private func btnCancelSubscriptionTapped(_ sender: UIButton) {
        AnalyticsManager.trackMatomoEvent(category: .appMenuCategory,
                                          action: AnalyticsManager.MatomoAction.appManageСancelPlanClickAction.rawValue,
                                          name: AnalyticsManager.MatomoName.clickName)

        let subscriptionSource = AppSessionManager.shared.decodedJWTToken?.subscription?.subscriptionSource
        switch subscriptionSource {
        case .ios:
            if let appStoreSubscriptionURL = URL(string: Constants.appleNativeSubscriptions.rawValue) {
                UIApplication.shared.open(appStoreSubscriptionURL, options: [:], completionHandler: nil)
            }
        default:
            self.btnCancelSubscription.startIndicator()
            self.performUpdateCancelSubscriptionAction(completion: { [weak self] in
                guard let self = self else { return }
                self.btnCancelSubscription.stopIndicator()
            })
        }
    }
    
    private func performUpdateCancelSubscriptionAction(completion: (() -> Void)?) {
        self.viewModel.getLinkForManagingSubscription(onSuccess: { [weak self] managingSubscriptionModel in
            if let linkString = managingSubscriptionModel.manageSubscriptionLink,
               let linkForManagingSubscription = URL(string: linkString) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(linkForManagingSubscription, options: [:], completionHandler: nil)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                    guard let self = self else { return }
                    self.motionDismissViewController(animated: true)
                })
            } else {
                let error = CustomError.somethingWentWrong
                UIUtils.showOkAlertInNewWindow(title: error.errorName, message: error.errorDescription)
            }
            
            completion?()
        },
                                                      onFailure: { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIUtils.showOkAlertInNewWindow(title: error.errorName, message: error.errorDescription)
            }
            completion?()
        })
    }
    
    @objc private func btnContinueTapped(_ sender: UIButton) {
        if self.viewModel.isOnboarding {
            AnalyticsManager.trackMatomoEvent(category: .appOnboardCategory,
                                              action: AnalyticsManager.MatomoAction.appOnbCreateAccContinueWithoutPremiumClickAction.rawValue,
                                              name: AnalyticsManager.MatomoName.clickName)
            let vc = OnboardingSetDefaultBrowserVC(source: .createAccount)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.motionDismissViewController(animated: true)
        }
    }
    
    @objc private func btnCloseNotOnboardingAction(_ sender: UIButton) {
        self.motionDismissViewController(animated: true)
    }
}

// MARK: - Add Scroll View

extension SubscriptionsVC {
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

extension SubscriptionsVC {
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
}

// MARK: - Add Bottom Buttons View

extension SubscriptionsVC {
    private func setupBottomButtonsView() {
        self.lblDescription.text = self.viewModel.descriptionText
        self.bottomButtonsView.updateButtonsSpacing(to: 16)
        self.setSubscriptionButtonsTitle()
        self.btnUpdateSubscription.setTitle("Update Plan", for: .normal)
        self.btnCancelSubscription.setTitle("Cancel Plan", for: .normal)
        
        self.btnRestorePurchases.configure(lblTitleText: "Already have premium?",
                                           btnTitleText: "Restore Purchase")
        
        self.btnContinue.setTitle(self.viewModel.btnContinueTitleText, for: .normal)
        
        switch self.viewModel.subscriptionType {
        case .trialExpired:
            self.bottomButtonsView.addViews(views: [self.btnMonthlySubscription,
                                                    self.btnYearlySubscription,
                                                    self.btnRestorePurchases,
                                                    self.btnContinue])
        case .originalApple:
            self.bottomButtonsView.addViews(views: [self.btnUpdateSubscription,
                                                    self.btnCancelSubscription,
                                                    self.btnRestorePurchases,
                                                    self.btnContinue])
        case .notApple:
            self.bottomButtonsView.addViews(views: [self.btnCancelSubscription,
                                                    self.btnRestorePurchases,
                                                    self.btnContinue])
        case nil:
            self.bottomButtonsView.addViews(views: [self.lblDescription,
                                                    self.btnMonthlySubscription,
                                                    self.btnYearlySubscription,
                                                    self.btnRestorePurchases,
                                                    self.btnContinue])
        }
    }
    
    private func setSubscriptionButtonsTitle() {
        let monthPrice = self.viewModel.monthlySubscription?.displayPrice ?? " - "
        let yearPrice = self.viewModel.yearlySubscription?.displayPrice ?? " - "
        
        self.btnMonthlySubscription.setAttributedTitle(self.makeAttributedTextForPriceButton(price: monthPrice,
                                                                                             period: "MONTH"),
                                                       for: .normal)
        self.btnYearlySubscription.setAttributedTitle(self.makeAttributedTextForPriceButton(price: yearPrice,
                                                                                            period: "YEAR"),
                                                      for: .normal)
    }
    
    private func makeAttributedTextForPriceButton(price: String, period: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "\(price) / \(period)")
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.sourceSansProFont(.bold, size: 18)
        ]
        let range = (attributedString.string as NSString).range(of: price)
        attributedString.addAttributes(boldAttributes, range: range)
        
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.sourceSansProFont(.regular, size: 18)
        ]
        let range2 = (attributedString.string as NSString).range(of: "/ \(period)")
        attributedString.addAttributes(regularAttributes, range: range2)
        
        return attributedString
    }
}

// MARK: Navigation

extension SubscriptionsVC {
    private func openPremiumUnlockedScreen() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.viewModel.isOnboarding {
                let vc = PremiumUnlockedVC(isOnboarding: true)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = PremiumUnlockedVC(isOnboarding: false)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: SubscriptionsVCViewModelDelegate

extension SubscriptionsVC: SubscriptionsVCViewModelDelegate {
    func premiumSuccessfullyUnlocked() {
        self.openPremiumUnlockedScreen()
    }
}
