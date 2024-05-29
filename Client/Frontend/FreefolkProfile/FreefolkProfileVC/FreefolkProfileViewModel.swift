// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared

protocol FreefolkProfileViewModelProtocol: AnyObject {
    func profileModelDidUpdateData(freespokeJWTDecodeModel: FreespokeJWTDecodeModel?)
    func showWarningForPremiumCell()
    func reloadTableView()
}

enum CellType {
    case verifyEmail
    case premium
    case account
    case adBlocker
    case darkMode
    case manageDefaultBrowser
    case manageNotifications
    case getInTouch
    case shareFreespoke
    case logout
    
    var title: String {
        switch self {
        case .verifyEmail: return "Verify Email"
        case .premium: return "Premium"
        case .account: return "Account"
        case .adBlocker: return ""
        case .darkMode: return "App Theme"
        case .manageDefaultBrowser: return "Manage Default Browser"
        case .manageNotifications: return "Manage Notifications"
        case .getInTouch: return "Get in Touch"
        case .shareFreespoke: return "Share Freespoke"
        case .logout: return "Log Out"
        }
    }
}

class FreefolkProfileViewModel {
    var freespokeJWTDecodeModel: FreespokeJWTDecodeModel? {
        guard let freespokeJWTDecodeModel = AppSessionManager.shared.decodedJWTToken else { return nil }
        return freespokeJWTDecodeModel
    }
    
    weak var delegate: FreefolkProfileViewModelProtocol?
    
    var currentTheme: Theme?
    private var cellTypes: [CellType] = []
    
    var shouldShowWarningForPremiumCell: Bool = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init() {
        self.subscribeNotifications()
        self.setupCellTypes()
        self.updateShowWarningForPremium()
    }
    
    func getFreespokeJWTDecodeModel() -> FreespokeJWTDecodeModel? {
        return freespokeJWTDecodeModel
    }
    
    func setupCellTypes() {
        self.cellTypes = []
        Task {
            if let userType = try? await AppSessionManager.shared.userType() {
                switch userType {
                case .authorizedWithoutPremium:
                    self.cellTypes = [
                        .premium,
                        .account,
                        .darkMode,
                        .manageDefaultBrowser,
                        .manageNotifications,
                        .getInTouch,
                        .shareFreespoke,
                        .logout
                    ]
                    
                    // MARK: this functionality is hidden for now, but it will be used in the future. Please don't remome this!!!
                    /*
                    if let decodedJWTToken = AppSessionManager.shared.decodedJWTToken, !decodedJWTToken.emailVerified {
                        self.cellTypes.insert(.verifyEmail, at: 0)
                    }
                    */
                    self.delegate?.reloadTableView()
                    
                case .premiumOriginalApple, .premiumNotApple, .premiumBecauseAppleAccountHasSubscription, .unauthorizedWithPremium:
                    self.cellTypes = [
                        .premium,
                        .account,
                        .darkMode,
                        .manageDefaultBrowser,
                        .manageNotifications,
                        .getInTouch,
                        .shareFreespoke,
                        .logout
                    ]
                    // MARK: this functionality is hidden for now, but it will be used in the future. Please don't remome this!!!
                    /*
                    if let decodedJWTToken = AppSessionManager.shared.decodedJWTToken, !decodedJWTToken.emailVerified {
                        self.cellTypes.insert(.verifyEmail, at: 0)
                    }
                    */
                     
                    if !self.cellTypes.contains(.verifyEmail) {
                        self.cellTypes.insert(.adBlocker, at: 2)
                    } else {
                        self.cellTypes.insert(.adBlocker, at: 3)
                    }
                    
                    self.delegate?.reloadTableView()
                case .unauthorizedWithoutPremium:
                    self.cellTypes = [
                        .premium,
                        .account,
                        .darkMode,
                        .manageDefaultBrowser,
                        .manageNotifications,
                        .getInTouch,
                        .shareFreespoke
                    ]
                    self.delegate?.reloadTableView()
                }
            }
        }
    }
    
    func getCellTypes() -> [CellType] {
        return self.cellTypes
    }
        
    func updateShowWarningForPremium() {
//        guard AppSessionManager.shared.decodedJWTToken != nil else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            Task {
                let userType = try await AppSessionManager.shared.userType()
                switch userType {
                case .premiumBecauseAppleAccountHasSubscription, .unauthorizedWithPremium:
                    self.shouldShowWarningForPremiumCell = true
                    self.delegate?.showWarningForPremiumCell()
                case .unauthorizedWithoutPremium, .authorizedWithoutPremium, .premiumOriginalApple, .premiumNotApple:
                    self.shouldShowWarningForPremiumCell = false
                    break
                }
            }
        }
    }
    
    func performLogout() {
        AppSessionManager.shared.performFreespokeLogout(completion: nil)
    }
    
    func getWhiteListDomainsCount() -> Int {
        guard let domains = UserDefaults.standard.object(forKey: SettingsKeys.domains) as? [String] else { return 0 }
        return domains.count
    }
}

// MARK: Subscriptions for Notifications

extension FreefolkProfileViewModel {
    private func subscribeNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.freespokeUserAuthChanged(_:)),
                                               name: Notification.Name.freespokeUserAuthChanged,
                                               object: nil)
    }
    
    @objc private func freespokeUserAuthChanged(_ notification: Notification) {
        self.updateShowWarningForPremium()
        self.delegate?.profileModelDidUpdateData(freespokeJWTDecodeModel: freespokeJWTDecodeModel)
        self.setupCellTypes()
    }
}
