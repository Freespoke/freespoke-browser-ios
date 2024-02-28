// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class SubscriptionsVC: OnboardingBaseViewController {
    private let viewModel: SubscriptionsVCViewModel
    private var inAppManager = InAppManager()
    private let scrollView = UIScrollView()
    private var scrollableContentView: SubscriptionsContentView!
    
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
    
    private lazy var btnMonthlySubscription: BaseButton = {
        let btn = BaseButton(style: .greenStyle(currentTheme: self.currentTheme))
        btn.height = 56
        return btn
    }()
    
    private lazy var btnYearlySubscription: BaseButton = {
        let btn = BaseButton(style: .greenStyle(currentTheme: self.currentTheme))
        btn.height = 56
        return btn
    }()
    
    private lazy var btnUpdateSubscription: BaseButton = {
        let btn = BaseButton(style: .greenStyle(currentTheme: self.currentTheme))
        btn.height = 56
        return btn
    }()
    
    private lazy var btnCancelSubscription: BaseButton = {
        let btn = BaseButton(style: .clearStyle(currentTheme: self.currentTheme))
        btn.height = 56
        return btn
    }()
    
    private var btnRestorePurchases = LabelWithUnderlinedButtonView()
    
    private let btnContinue: UnderlinedButton = {
        let btn = UnderlinedButton()
        btn.titleLabel?.font = UIFont.sourceSansProFont(.regular, size: 16)
        btn.setTitleColor(UIColor.blackColor, for: .normal)
        return btn
    }()
    
    init(currentTheme: Theme?, viewModel: SubscriptionsVCViewModel) {
        self.viewModel = viewModel
        super.init(currentTheme: currentTheme)
        self.viewModel.delegate = self
        self.scrollableContentView = SubscriptionsContentView(currentTheme: self.currentTheme)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.AppUtility.lockOrientation(.portrait)
        
        self.navigationController?.viewControllers.removeAll(where: { $0 is SignUpVC })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.contentInset.bottom = self.bottomButtonsView.frame.height
    }
    
    private func setupUI() {
        self.scrollableContentView.configure(currentTheme: self.currentTheme,
                                             lblTitleText: self.viewModel.titleText,
                                             lblSubtitleText: self.viewModel.subtitleText)
        
        self.setupBottomButtonsView()
        
        self.applyTheme()
        self.btnRestorePurchases.tapClosure = { [weak self] in
            self?.inAppManager.restorePurchases(completionHandler: { status in
                switch status {
                case .canNotMakePayments:
                    UIUtils.showOkAlert(title: status.userMessage, message: "")
                case .noTransactionsToRestore:
                    UIUtils.showOkAlert(title: status.userMessage, message: "")
                case .restorePurchasesRequestFailed:
                    UIUtils.showOkAlert(title: status.userMessage, message: "")
                case .restored:
                    UIUtils.showOkAlert(title: status.userMessage, message: "")
                case .failed:
                    UIUtils.showOkAlert(title: status.userMessage, message: "")
                }
            })
        }
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            switch theme.type {
            case .dark:
                self.lblDescription.textColor = UIColor.lightGray
                self.btnContinue.setTitleColor(UIColor.whiteColor, for: .normal)
            case .light:
                self.lblDescription.textColor = UIColor.blackColor
                self.btnContinue.setTitleColor(UIColor.blackColor, for: .normal)
            }
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
        if case .startTrialSubscription(let isOnboarding) = self.viewModel.state,
           isOnboarding {
            self.addOnboardingCloseAction()
        } else {
            self.btnClose.addTarget(self,
                                    action: #selector(self.btnCloseNotOnboardingAction(_:)),
                                    for: .touchUpInside)
        }
    }
    
    private func purchaseMonthlySubscription() {
        self.btnMonthlySubscription.startIndicator()
        guard let appAccountToken = AppSessionManager.shared.decodedJWTToken?.externalAccountId else {
            self.btnMonthlySubscription.stopIndicator()
            return
        }
        if let product = self.inAppManager.products.first(where: { $0.id == ProductIdentifiers.monthlySubscription }) {
            Task {
                if await self.inAppManager.purchase(product, appAccountToken: appAccountToken) {
                    AppSessionManager.shared.performRefreshFreespokeToken(completion: nil)
                    self.btnMonthlySubscription.stopIndicator()
                    self.openPremiumUnlockedScreen()
                } else {
                    self.btnMonthlySubscription.stopIndicator()
                }
            }
        }
    }
    
    private func purchaseYearlySubscription() {
        self.btnYearlySubscription.startIndicator()
        guard let appAccountToken = AppSessionManager.shared.decodedJWTToken?.externalAccountId else {
            self.btnYearlySubscription.stopIndicator()
            return
        }
        if let product = self.inAppManager.products.first(where: { $0.id == ProductIdentifiers.yearlySubscription }) {
            Task {
                if await self.inAppManager.purchase(product, appAccountToken: appAccountToken) {
                    AppSessionManager.shared.performRefreshFreespokeToken(completion: nil)
                    self.btnYearlySubscription.stopIndicator()
                    self.openPremiumUnlockedScreen()
                } else {
                    self.btnYearlySubscription.stopIndicator()
                }
            }
        }
    }
    
    @objc private func btnMonthlySubscriptionTapped(_ sender: UIButton) {
        self.purchaseMonthlySubscription()
    }
    
    @objc private func btnYearlySubscriptionTapped(_ sender: UIButton) {
        self.purchaseYearlySubscription()
    }
    
    @objc private func btnUpdateSubscriptionTapped(_ sender: UIButton) {
        guard let subscriptionSource = AppSessionManager.shared.decodedJWTToken?.subscription?.subscriptionSource else { return }
        switch subscriptionSource {
        case .ios:
            if let appStoreSubscriptionURL = URL(string: Constants.appleNativeSubscriptions.rawValue) {
                UIApplication.shared.open(appStoreSubscriptionURL, options: [:], completionHandler: nil)
            }
        case .android:
            return
        case .web:
            return
        }
    }
    
    @objc private func btnCancelSubscriptionTapped(_ sender: UIButton) {
        guard let subscriptionSource = AppSessionManager.shared.decodedJWTToken?.subscription?.subscriptionSource else { return }
        switch subscriptionSource {
        case .ios:
            if let appStoreSubscriptionURL = URL(string: Constants.appleNativeSubscriptions.rawValue) {
                UIApplication.shared.open(appStoreSubscriptionURL, options: [:], completionHandler: nil)
            }
        case .android:
            if let appStoreSubscriptionURL = URL(string: Constants.androidNativeSubscriptions.rawValue) {
                UIApplication.shared.open(appStoreSubscriptionURL, options: [:], completionHandler: nil)
            }
        case .web:
            if let appStoreSubscriptionURL = URL(string: Constants.webSubscriptions.rawValue) {
                UIApplication.shared.open(appStoreSubscriptionURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc private func btnContinueTapped(_ sender: UIButton) {
        if case .startTrialSubscription(let isOnboarding) = self.viewModel.state,
           isOnboarding {
            let vc = OnboardingSetDefaultBrowserVC(currentTheme: self.currentTheme)
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
        
        self.btnMonthlySubscription.setAttributedTitle(self.makeAttributedTextForPriceButton(price: "5.00", period: "MONTH"), for: .normal)
        self.btnYearlySubscription.setAttributedTitle(self.makeAttributedTextForPriceButton(price: "30.00", period: "YEAR"), for: .normal)
        
        self.btnUpdateSubscription.setTitle("Update Plan", for: .normal)
        self.btnCancelSubscription.setTitle("Cancel Plan", for: .normal)
        
        self.btnRestorePurchases.configure(currentTheme: self.currentTheme,
                                           lblTitleText: "Already have premium?",
                                           btnTitleText: "Restore Purchase")
        
        self.btnContinue.setTitle(self.viewModel.btnContinueTitleText, for: .normal)
        
        switch self.viewModel.state {
        case .startTrialSubscription:
            self.bottomButtonsView.addViews(views: [self.lblDescription,
                                                    self.btnMonthlySubscription,
                                                    self.btnYearlySubscription,
                                                    self.btnRestorePurchases,
                                                    self.btnContinue])
        case .trialExpired:
            self.bottomButtonsView.addViews(views: [self.btnMonthlySubscription,
                                                    self.btnYearlySubscription,
                                                    self.btnRestorePurchases,
                                                    self.btnContinue])
        case .updatePlan:
            self.bottomButtonsView.addViews(views: [self.btnUpdateSubscription,
                                                    self.btnCancelSubscription,
                                                    self.btnRestorePurchases,
                                                    self.btnContinue])
        case .cancelPlanNotOriginalOS:
            self.bottomButtonsView.addViews(views: [self.btnCancelSubscription,
                                                    self.btnRestorePurchases,
                                                    self.btnContinue])
        }
        
        self.bottomButtonsView.configure(currentTheme: self.currentTheme)
    }
    
    private func makeAttributedTextForPriceButton(price: String, period: String) -> NSMutableAttributedString {
        let priceMonth = "$\(price)"
        let attributedString = NSMutableAttributedString(string: "\(priceMonth) / \(period)")
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.sourceSansProFont(.bold, size: 18)
        ]
        let range = (attributedString.string as NSString).range(of: priceMonth)
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
        if case .startTrialSubscription(let isOnboarding) = self.viewModel.state,
           isOnboarding {
            let vc = PremiumUnlockedVC(currentTheme: self.currentTheme, isOnboarding: true)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = PremiumUnlockedVC(currentTheme: self.currentTheme, isOnboarding: false)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension SubscriptionsVC: SubscriptionsVCViewModelProtocol {}
