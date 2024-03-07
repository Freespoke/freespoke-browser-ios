// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

final class BlockerAdsCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: type(of: BlockerAdsCell.self))
    
    private let contentBlockAdsView: UIView = {
        let view = UIView()
        return view
    }()
    
    let viewSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.neutralsGray5
        view.setSizeToView(height: 1)
        return view
    }()
    
    let imgIcon: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "imgBlock")
        imgView.setSizeToView(width: 25, height: 25)
        return imgView
    }()

    private let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.sourceSansProFont(.semiBold, size: 19)
        lbl.text = LocalizationConstants.adBlockStr
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let adBlockerSwitcher: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.isEnabledBlocker)
        switcher.onTintColor = .greenColor
        return switcher
    }()

    private let btnAction: BaseButton = {
        let btn = BaseButton(style: .greyStyle(currentTheme: nil))
        btn.setTitle(LocalizationConstants.manageBlockStr, for: .normal)
        return btn
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.imgIcon, self.lblTitle, self.adBlockerSwitcher])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var stackViewVertical: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [self.stackView, self.viewSeparator, self.btnAction])
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()
    
    private var borderView: UIView = {
        let view =  UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 4.0
        view.layer.masksToBounds = true
        return view
    }()
    
    private var currentTheme: Theme? {
        didSet {
            self.btnAction.setStyle(style: .greyStyle(currentTheme: self.currentTheme))
        }
    }
        
    var closureTappedOnBtnSwitch: (() -> Void)?
    var closureTappedOnBtnManage: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.prepareUI()
        self.addingViews()
        self.configureConstraints()
        self.checkAdBlockerStatus()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareUI() {
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.adBlockerSwitcher.addTarget(self, action: #selector(self.tappedOnBtnSwitcher(_:)), for: .touchUpInside)
        self.btnAction.addTarget(self, action: #selector(self.tappedOnBtnManage), for: .touchUpInside)
    }
    
    func addingViews() {
        self.contentView.addSubview(self.borderView)
        self.borderView.addSubview(self.stackViewVertical)
    }
    
    func configureConstraints() {
        self.borderView.translatesAutoresizingMaskIntoConstraints = false
        self.stackViewVertical.translatesAutoresizingMaskIntoConstraints = false
        self.borderView.pinToView(view: self.contentView, withInsets: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        self.stackViewVertical.pinToView(view: self.borderView, withInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    @objc private func tappedOnBtnSwitcher(_ sender: UISwitch) {
        print("sender.isOn: \(sender.isOn)")
        UserDefaults.standard.setValue(sender.isOn, forKey: SettingsKeys.isEnabledBlocker)
        self.checkAdBlockerStatus()
        self.closureTappedOnBtnSwitch?()
    }
    
    func checkAdBlockerStatus() {
        let isOn = UserDefaults.standard.bool(forKey: SettingsKeys.isEnabledBlocker)
        switch isOn {
        case true:
            self.viewSeparator.isHidden = false
            self.btnAction.isHidden = false
        case false:
            self.viewSeparator.isHidden = true
            self.btnAction.isHidden = true
        }
        self.adBlockerSwitcher.isOn = isOn
    }
    
    @objc private func tappedOnBtnManage() {
        self.closureTappedOnBtnManage?()
    }
    
    func setCurrentTheme(currentTheme: Theme?) {
        self.currentTheme = currentTheme
    }
}
