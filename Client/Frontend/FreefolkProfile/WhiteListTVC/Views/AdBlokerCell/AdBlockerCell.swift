// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

final class AdBlockerCell: UITableViewCell {
    static let reuseIdentifier = String(describing: type(of: AdBlockerCell.self))
        
    let imgIcon: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "imgBlock")
        imgView.setSizeToView(width: 20, height: 20)
        return imgView
    }()

    private let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.sourceSansProFont(.semiBold, size: 19)
        lbl.text = LocalizationConstants.blockAdsStr
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let adBlockerSwitcher: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.isEnabledBlocker)
        switcher.onTintColor = .greenColor
        return switcher
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.imgIcon, self.lblTitle, self.adBlockerSwitcher])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    private var borderView: UIView = {
        let view =  UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.whiteColor.cgColor
        view.layer.cornerRadius = 4.0
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    private var currentTheme: Theme?
        
    var closureTappedOnBtnSwitch: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.prepareUI()
        self.addingViews()
        self.configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareUI() {
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.adBlockerSwitcher.addTarget(self, action: #selector(self.tappedOnBtnSwitcher(_:)), for: .touchUpInside)
    }
    
    func addingViews() {
        self.contentView.addSubview(self.borderView)
        self.borderView.addSubview(self.stackView)
    }
    
    func applyTheme(currentTheme: Theme) {
        self.currentTheme = currentTheme
        self.applyTheme()
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            self.borderView.layer.borderColor = (theme.type == .light) ? UIColor.whiteColor.cgColor : UIColor.blackColor.cgColor
            self.borderView.backgroundColor = (theme.type == .light) ? UIColor.white : UIColor.clear
        }
    }
    
    func configureConstraints() {
        self.borderView.translatesAutoresizingMaskIntoConstraints = false
        self.borderView.pinToView(view: self.contentView, withInsets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        self.stackView.pinToView(view: self.borderView, withInsets: UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20))
    }
    
    @objc private func tappedOnBtnSwitcher(_ sender: UISwitch) {
        print("sender.isOn: \(sender.isOn)")
        UserDefaults.standard.setValue(sender.isOn, forKey: SettingsKeys.isEnabledBlocker)
        NotificationCenter.default.post(name: Notification.Name.adBlockSettingsChanged, object: nil)
        self.closureTappedOnBtnSwitch?()
    }
}
