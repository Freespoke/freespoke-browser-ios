// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import OneSignal
import Common

class FreefolkProfileVC: UIViewController, Themeable {
    private var viewModel: FreefolkProfileViewModel
    private var contentView: UIView = {
        let cv = UIView()
        return cv
    }()
    
    private var customTitleView = CustomTitleView()
    
    private var titleLbl: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "FREEFOLK PROFILE"
        titleLabel.font = UIFont.sourceSansProFont(.bold, size: 20)
        
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private var tableView = UITableView()
    
    var themeManager: ThemeManager
    var notificationCenter: NotificationProtocol
    var themeObserver: NSObjectProtocol?
    
    var getInTouchClosure: (() -> Void)?
    var accountClickedClosure: (() -> Void)?
    var appThemeClickedClosure: (() -> Void)?
    
    init(viewModel: FreefolkProfileViewModel, themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default) {
        self.viewModel = viewModel
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
        self.setupTableView()
        self.subscribeClosures()
        self.viewModel.delegate = self
        
        self.listenForThemeChange(self.view)
        self.applyTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.customTitleView.updateProfileIcon(freespokeJWTDecodeModel: self.viewModel.freespokeJWTDecodeModel)
    }
    
    private func prepareUI() {
        self.customTitleView.updateProfileIcon(freespokeJWTDecodeModel: self.viewModel.freespokeJWTDecodeModel)
    }
    
    private func addingViews() {
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.titleLbl)
        self.contentView.addSubview(self.tableView)
        self.view.addSubview(self.customTitleView)
    }
    
    private func setupConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.customTitleView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: constraints are set depending on the type of device iPad or iPhone
        if UIDevice.current.isPad {
            NSLayoutConstraint.activate([
                self.contentView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
                self.contentView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 0),
                self.contentView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: 0),
                self.contentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.contentView.widthAnchor.constraint(equalToConstant: (self.view.frame.width * Constants.DrawingSizes.iPadContentWidthFactorPortrait)),
                self.contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                self.titleLbl.topAnchor.constraint(equalTo: customTitleView.bottomAnchor, constant: 50)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.contentView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
                self.contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                
                self.titleLbl.topAnchor.constraint(equalTo: customTitleView.bottomAnchor, constant: 20),
            ])
        }
        NSLayoutConstraint.activate([
            self.customTitleView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            self.customTitleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
            self.customTitleView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40),
            
            self.titleLbl.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            self.titleLbl.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            
            self.tableView.topAnchor.constraint(equalTo: self.titleLbl.bottomAnchor, constant: 10),
            self.tableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            self.tableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        ])
    }
    
    func applyTheme() {
        self.customTitleView.applyTheme(currentTheme: self.themeManager.currentTheme)
        
        switch self.themeManager.currentTheme.type {
        case .dark:
            self.view.backgroundColor = UIColor.black
            self.tableView.backgroundColor = .clear
            self.titleLbl.textColor = .gray7
        case .light:
            self.view.backgroundColor = .gray7
            self.tableView.backgroundColor = .gray7
            self.titleLbl.textColor = .blackColor
        }
        
        self.tableView.reloadData()
    }
    
    private func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(VerifyEmailCell.self, forCellReuseIdentifier: VerifyEmailCell.identifier)
        self.tableView.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.identifier)
        self.tableView.register(LogoutCell.self, forCellReuseIdentifier: LogoutCell.identifier)
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44
        self.tableView.allowsSelection = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
    }
    
    func subscribeClosures() {
        self.customTitleView.backButtonTappedClosure = { [weak self] in
            self?.motionDismissViewController(animated: true)
        }
    }
    
    private func premiumClicked() {
        if self.viewModel.freespokeJWTDecodeModel != nil {
            self.navigateToSubscriptionScreen()
        } else {
            let vc = SignUpVC(viewModel: SignUpVCViewModel(isOnboarding: false))
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func navigateToSubscriptionScreen() {
        let vc = SubscriptionsVC(viewModel: SubscriptionsVCViewModel(isOnboarding: false))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func shareFreespoke() {
        guard let url = URL(string: Constants.freespokeURL.rawValue) else { return }
        let helper = ShareExtensionHelper(url: url, tab: nil)
        let controller = helper.createActivityViewController { _, _ in }
        if let popoverPresentationController = controller.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
            popoverPresentationController.permittedArrowDirections = .up
        }
        AnalyticsManager.trackMatomoEvent(category: .appShareCategory,
                                          action: AnalyticsManager.MatomoAction.appShareFromProfileMenuAction.rawValue,
                                          name: AnalyticsManager.MatomoName.clickName)
        TelemetryWrapper.recordEvent(category: .action,
                                     method: .tap,
                                     object: .sharePageWith)
        self.presentWithModalDismissIfNeeded(controller, animated: true)
    }
    
    private func showDeviceAppSettings() {
        guard let appBundleIdentifier = Bundle.main.bundleIdentifier,
              let url = URL(string: UIApplication.openSettingsURLString + appBundleIdentifier),
              UIApplication.shared.canOpenURL(url) else { return }
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension FreefolkProfileVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getCellTypes().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = self.viewModel.getCellTypes()[indexPath.row]
        
        switch cellType {
        case .verifyEmail:
            return self.prepareVerifyEmailCell(with: cellType.title, at: indexPath)
        case .premium, .account, .manageDefaultBrowser, .manageNotifications, .getInTouch, .shareFreespoke, .darkMode:
            return self.getProfileCell(for: cellType, at: indexPath)
        case .logout:
            return self.getLogoutCell(at: indexPath)
        }
    }
    
    private func prepareVerifyEmailCell(with title: String, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VerifyEmailCell.identifier, for: indexPath) as? VerifyEmailCell else {
            return UITableViewCell()
        }
        cell.configure(title: title, subtitle: "Check your email for a message to confirm your account.", currentTheme: self.themeManager.currentTheme)
        return cell
    }
    
    // TODO: Move function to the viewModel
    private func getProfileCell(for cellType: CellType, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell else {
            return UITableViewCell()
        }
        
        self.configureProfileCell(cell, for: cellType)
        return cell
    }
    
    private func getLogoutCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LogoutCell.identifier, for: indexPath) as? LogoutCell else {
            return UITableViewCell()
        }
        
        self.configureLogoutCell(cell)
        return cell
    }
    
    private func configureProfileCell(_ cell: ProfileCell, for cellType: CellType) {
        cell.configure(with: cellType, currentTheme: self.themeManager.currentTheme)
        
        let theme = self.themeManager.currentTheme
        cell.backgroundColor = (theme.type == .light) ? .gray7 : .clear
        
        switch cellType {
        case .premium:
            cell.tapClosure = { [weak self] in
                AnalyticsManager.trackMatomoEvent(category: .appProfileCategory,
                                                  action: AnalyticsManager.MatomoAction.appProfileScreenAction.rawValue + "premium",
                                                  name: AnalyticsManager.MatomoName.clickName)
                self?.premiumClicked()
            }
        case .account:
            cell.tapClosure = { [weak self] in
                AnalyticsManager.trackMatomoEvent(category: .appProfileCategory,
                                                  action: AnalyticsManager.MatomoAction.appProfileScreenAction.rawValue + "account",
                                                  name: AnalyticsManager.MatomoName.clickName)
                self?.accountCellClicked()
            }
        case .darkMode:
            cell.tapClosure = { [weak self] in
                AnalyticsManager.trackMatomoEvent(category: .appProfileCategory,
                                                  action: AnalyticsManager.MatomoAction.appProfileScreenAction.rawValue + "app theme",
                                                  name: AnalyticsManager.MatomoName.clickName)
                self?.appThemeClickedClosure?()
            }
        case .manageDefaultBrowser:
            cell.tapClosure = { [weak self] in
                AnalyticsManager.trackMatomoEvent(category: .appProfileCategory,
                                                  action: AnalyticsManager.MatomoAction.appProfileScreenAction.rawValue + "manage default browser",
                                                  name: AnalyticsManager.MatomoName.clickName)
                self?.showDeviceAppSettings()
            }
        case .manageNotifications:
            cell.tapClosure = { [weak self] in
                AnalyticsManager.trackMatomoEvent(category: .appProfileCategory,
                                                  action: AnalyticsManager.MatomoAction.appProfileScreenAction.rawValue + "manage notifications",
                                                  name: AnalyticsManager.MatomoName.clickName)
                self?.manageNotificationClicked()
            }
            
        case .getInTouch:
            cell.tapClosure = { [weak self] in
                AnalyticsManager.trackMatomoEvent(category: .appProfileCategory,
                                                  action: AnalyticsManager.MatomoAction.appProfileScreenAction.rawValue + "get in touch",
                                                  name: AnalyticsManager.MatomoName.clickName)
                self?.getInTouchClosure?()
            }
        case .shareFreespoke:
            cell.tapClosure = { [weak self] in
                AnalyticsManager.trackMatomoEvent(category: .appProfileCategory,
                                                  action: AnalyticsManager.MatomoAction.appProfileScreenAction.rawValue + "share freespoke",
                                                  name: AnalyticsManager.MatomoName.clickName)
                self?.shareFreespoke()
            }
        default:
            cell.tapClosure = { }
            break
        }
    }
    
    private func manageNotificationClicked() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] notificationsSettings in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch notificationsSettings.authorizationStatus {
                case .notDetermined:
                    // Ask for setup notification setting
                    OneSignal.promptForPushNotifications(userResponse: { accepted in
                        print("User accepted notification: \(accepted)")
                    })
                default:
                    self.showDeviceAppSettings()
                }
            }
        }
    }
    
    private func accountCellClicked() {
//        self.accountClickedClosure?()
        guard let accountURL = URL(string: Constants.URLs.accountProfileURL) else { return }
        
        DispatchQueue.main.async {
            let vc = OAuthLoginVC(activityIndicatorEnabled: false, source: .accountPage)
            vc.startLoadingWebView(url: accountURL)
            vc.isModalInPresentation = true
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func configureLogoutCell(_ cell: LogoutCell) {
        let theme = self.themeManager.currentTheme
        cell.backgroundColor = (theme.type == .light) ? .gray7 : .clear
        cell.configureCell(textColor: (theme.type == .light) ? .blackColor : .whiteColor)
        
        cell.tapClosure = { [weak self] in
            AnalyticsManager.trackMatomoEvent(category: .appProfileCategory,
                                              action: AnalyticsManager.MatomoAction.appProfileScreenAction.rawValue + "logout",
                                              name: AnalyticsManager.MatomoName.clickName)
            self?.viewModel.performLogout()
        }
    }
}

extension FreefolkProfileVC: FreefolkProfileViewModelProtocol {
    func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func profileModelDidUpdateData(freespokeJWTDecodeModel: FreespokeJWTDecodeModel?) {
        self.customTitleView.updateProfileIcon(freespokeJWTDecodeModel: freespokeJWTDecodeModel)
    }
}
