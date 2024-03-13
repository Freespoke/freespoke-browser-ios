// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

class AdBlockerSwitcherView: UIView {
    
    private let adBlockerSwitcher: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.isEnabledBlocker)
        switcher.onTintColor = .greenColor
        return switcher
    }()
    
    private let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = .sourceSansProFont(.regular, size: 16)
        lbl.textColor = .gray2
        lbl.numberOfLines = 1
        lbl.text = LocalizationConstants.blockAdsOn
        lbl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return lbl
    }()
    
    private let lblSite: UILabel = {
        let lbl = UILabel()
        lbl.font = .sourceSansProFont(.regular, size: 16)
        lbl.textColor = .neutralsGray01
        lbl.numberOfLines = 1
        lbl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return lbl
    }()
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
        self.subscribeToNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(domainWasRemoved), name: NSNotification.Name.domainWasRemoved, object: nil)
    }
    
    private func prepareUI() {
        self.backgroundColor = .clear
        self.adBlockerSwitcher.addTarget(self, action: #selector(self.tappedOnBtnSwitcher(_:)), for: .touchUpInside)
    }
    
    private func addingViews() {
        self.addSubview(self.adBlockerSwitcher)
        self.addSubview(self.lblTitle)
        self.addSubview(self.lblSite)
    }
    
    private func setupConstraints() {
        self.adBlockerSwitcher.translatesAutoresizingMaskIntoConstraints = false
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.lblSite.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.adBlockerSwitcher.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            self.adBlockerSwitcher.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            self.adBlockerSwitcher.trailingAnchor.constraint(equalTo: self.lblTitle.leadingAnchor, constant: -8),
            self.adBlockerSwitcher.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -8),
            
            self.lblTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            self.lblTitle.trailingAnchor.constraint(equalTo: self.lblSite.leadingAnchor, constant: -2),
            self.lblTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            
            self.lblSite.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            self.lblSite.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.lblSite.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
        ])
    }
    
    @objc private func tappedOnBtnSwitcher(_ sender: UISwitch) {
        print("sender.isOn: \(sender.isOn)")
        var domains = self.getDomains()
        guard let domain = self.lblSite.text else { return }
        if !sender.isOn {
            domains.insert(domain, at: 0)
        } else {
            for (index, domainItem) in domains.enumerated() where domainItem == domain {
                domains.remove(at: index)
            }
        }
        for item in domains {
            print("domain: \(item)")
        }
        UserDefaults.standard.set(domains, forKey: SettingsKeys.domains)
        NotificationCenter.default.post(name: Notification.Name.disableAdBlockerForCurrentDomain, object: nil)
    }
    
    private func getDomains() -> [String] {
        guard let domains = UserDefaults.standard.object(forKey: SettingsKeys.domains) as? [String] else { return [] }
        return domains
    }
    
    func setDomain(domain: URL?) {
        guard let domain = domain else { return }
        guard let host = domain.host else { return }
        self.isHidden = (host == "local") || AppSessionManager.shared.userType != .premium
        self.adBlockerSwitcher.isOn = !self.getDomains().contains(where: { $0 == host })
        self.lblSite.text = domain.hostPort
    }
    
    @objc private func domainWasRemoved() {
        guard let host = self.lblSite.text else { return }
        self.adBlockerSwitcher.isOn = !self.getDomains().contains(where: { $0 == host })
    }
}
