// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared

protocol FreefolkProfileViewModelProtocol: AnyObject {
    func profileModelDidUpdateData(freespokeJWTDecodeModel: FreespokeJWTDecodeModel?)
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
        case .darkMode: return "Dark Mode"
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init() {
        self.subscribeNotifications()
    }
    
    func getFreespokeJWTDecodeModel() -> FreespokeJWTDecodeModel? {
        return freespokeJWTDecodeModel
    }
    
    func getCellTypes() -> [CellType] {
        if let freespokeJWTDecodeModel = self.freespokeJWTDecodeModel {
            self.cellTypes = [
                .premium,
                .account,
                .adBlocker,
                //.darkMode, // dark mode is hidden for now
                .manageDefaultBrowser,
                .manageNotifications,
                .getInTouch,
                .shareFreespoke,
                .logout
            ]
            if !freespokeJWTDecodeModel.emailVerified {
                self.cellTypes.insert(.verifyEmail, at: 0)
            }
            return self.cellTypes
        } else {
            self.cellTypes = [
                .premium,
                .account,
                .adBlocker,
                //.darkMode, // dark mode is hidden for now
                .manageDefaultBrowser,
                .manageNotifications,
                .getInTouch,
                .shareFreespoke
            ]
            if AppSessionManager.shared.userType != .premium {
                for (index, cell) in self.cellTypes.enumerated() where cell == .adBlocker {
                    self.cellTypes.remove(at: index)
                }
            }
            return self.cellTypes
        }
    }
    
    func performLogout() {
        AppSessionManager.shared.performFreespokeLogout(completion: nil)
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
        self.delegate?.profileModelDidUpdateData(freespokeJWTDecodeModel: freespokeJWTDecodeModel)
        self.delegate?.reloadTableView()
    }
}
