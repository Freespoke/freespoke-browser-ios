// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import MatomoTracker

class FreefolkProfileVC: UIViewController {
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
    private var currentTheme: Theme?
    
    var getInTouchClosure: (() -> Void)?
    var accountTouchClosure: (() -> Void)?
    var darkModeSwitchClosure: ((_ isOn: Bool) -> Void)?
    
    init(viewModel: FreefolkProfileViewModel) {
        self.viewModel = viewModel
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
    }
    
    func setCurrentTheme(currentTheme: Theme) {
        self.currentTheme = currentTheme
        self.applyTheme()
    }
    
    private func prepareUI() {
        self.customTitleView.updateProfileIcon(freespokeJWTDecodeModel: self.viewModel.freespokeJWTDecodeModel)
    }
    
    private func addingViews() {
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(customTitleView)
        self.contentView.addSubview(titleLbl)
        self.contentView.addSubview(tableView)
        contentView.isUserInteractionEnabled = true
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
                self.contentView.widthAnchor.constraint(equalToConstant: Constants.UI.contentWidthConstraintForIpad),
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
            self.customTitleView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            self.customTitleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.customTitleView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.customTitleView.heightAnchor.constraint(equalToConstant: 60),
            
            self.titleLbl.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            self.titleLbl.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
        
            self.tableView.topAnchor.constraint(equalTo: self.titleLbl.bottomAnchor, constant: 10),
            self.tableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            self.tableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        ])
    }
    
    private func applyTheme() {
        if let theme = self.currentTheme {
            self.customTitleView.setCurrentTheme(currentTheme: theme)
            switch theme.type {
            case .dark:
                self.view.backgroundColor = UIColor.black
                self.tableView.backgroundColor = .clear
                self.titleLbl.textColor = .gray7
            case .light:
                self.view.backgroundColor = .gray7
                self.tableView.backgroundColor = .gray7
                self.titleLbl.textColor = .blackColor
            }
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
    }
    
    func subscribeClosures() {
        self.customTitleView.backButtonTapClosure = { [weak self] in
            self?.motionDismissViewController(animated: true)
        }
    }
    
    private func navigateToSubscriptionsVC() {
        if let freespokeJWTDecodeModel = self.viewModel.freespokeJWTDecodeModel {
            if freespokeJWTDecodeModel.isPremium {
                switch AppSessionManager.shared.decodedJWTToken?.subscription?.subscriptionSource {
                case .ios:
                    if let expiryDate = freespokeJWTDecodeModel.subscription?.subscriptionExpiry,
                       expiryDate < Date() {
                        self.navigateToSubscriptionTrialExpired()
                    } else {
                        self.navigateToSubscriptionUpdatePlan()
                    }
                default:
                    self.navigateToSubscriptionCancelPlanNotOriginalOS()
                }
            } else {
                self.navigateToSubscriptionStartTrial()
            }
        } else {
            let vc = SignUpVC(currentTheme: self.currentTheme, viewModel: SignUpVCViewModel(isOnboarding: false))
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func navigateToSubscriptionStartTrial() {
        let vc = SubscriptionsVC(currentTheme: self.currentTheme,
                                 viewModel: SubscriptionsVCViewModel(state: .startTrialSubscription(isOnboarding: false)))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToSubscriptionUpdatePlan() {
        let vc = SubscriptionsVC(currentTheme: self.currentTheme,
                                 viewModel: SubscriptionsVCViewModel(state: .updatePlan))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToSubscriptionTrialExpired() {
        let vc = SubscriptionsVC(currentTheme: self.currentTheme,
                                 viewModel: SubscriptionsVCViewModel(state: .trialExpired))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToSubscriptionCancelPlanNotOriginalOS() {
        let vc = SubscriptionsVC(currentTheme: self.currentTheme,
                                 viewModel: SubscriptionsVCViewModel(state: .cancelPlanNotOriginalOS))
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
        MatomoTracker.shared.track(eventWithCategory: MatomoCategory.appShare.rawValue,
                                   action: MatomoAction.appShareMenu.rawValue,
                                   name: MatomoName.click.rawValue,
                                   value: nil)
        TelemetryWrapper.recordEvent(category: .action,
                                     method: .tap,
                                     object: .sharePageWith)
        self.presentWithModalDismissIfNeeded(controller, animated: true)
    }
    
    private func showDeviceSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
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
        cell.configure(title: title, subtitle: "Check your email for a message to confirm your account.", currentTheme: self.currentTheme)
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
        cell.configure(with: cellType, currentTheme: currentTheme)
        
        if let theme = currentTheme {
            cell.backgroundColor = (theme.type == .light) ? .gray7 : .clear
        }
        
        switch cellType {
        case .premium:
            cell.tapClosure = { [weak self] in
                self?.navigateToSubscriptionsVC()
            }
        case .account:
            cell.tapClosure = { [weak self] in
                self?.accountTouchClosure?()
            }
        case .manageDefaultBrowser, .manageNotifications:
            cell.tapClosure = { [weak self] in
                self?.showDeviceSettings()
            }
        case .getInTouch:
            cell.tapClosure = { [weak self] in
                self?.getInTouchClosure?()
            }
        case .shareFreespoke:
            cell.tapClosure = { [weak self] in
                self?.shareFreespoke()
            }
        case .darkMode:
            cell.tapClosure = { }
            self.configureDarkModeCell(cell)
        default:
            cell.tapClosure = { }
            break
        }
    }
    
    private func configureLogoutCell(_ cell: LogoutCell) {
        if let theme = currentTheme {
            cell.backgroundColor = (theme.type == .light) ? .gray7 : .clear
            cell.configureCell(textColor: (theme.type == .light) ? .blackColor : .whiteColor)
        }
        cell.tapClosure = { [weak self] in
            self?.viewModel.performLogout()
        }
    }
    
    private func configureDarkModeCell(_ cell: ProfileCell) {
        let nightModeEnabled = NightModeHelper.isActivated()
        cell.setDarkModeSwich(isOn: nightModeEnabled)
        cell.darkModeSwitchClosure = { [weak self] isOn in
            self?.darkModeSwitchClosure?(isOn)
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
