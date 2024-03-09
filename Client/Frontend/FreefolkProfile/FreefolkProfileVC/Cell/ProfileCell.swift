// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

// MARK: - ProfileCell
class ProfileCell: UITableViewCell {
    static let identifier = String(describing: type(of: ProfileCell.self))
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.sourceSansProFont(.semiBold, size: 19)
        label.textColor = .blackColor
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "right_arrows"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        let stackView = UIStackView(arrangedSubviews: [iconImageView,
                                                       titleLabel,
                                                       arrowImageView,
                                                       darkModeSwitch])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    private var borderView = UIView()
    
    private let darkModeSwitch: UISwitch = {
        let darkModeSwitch = UISwitch()
        darkModeSwitch.isOn = false
        darkModeSwitch.onTintColor = .greenColor
        return darkModeSwitch
    }()
    
    var currentTheme: Theme?
    
    var tapClosure: (() -> Void)?
    var darkModeSwitchClosure: ((_ isOn: Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.prepareUI()
        self.addingViews()
        self.configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.borderView.layer.borderWidth = 1.0
        self.borderView.layer.borderColor = UIColor.lightGray.cgColor
        self.borderView.layer.cornerRadius = 4.0
        self.borderView.layer.masksToBounds = true
    }
    
    func prepareUI() {
        self.darkModeSwitch.addTarget(self, action: #selector(self.darkModeSwitchChanged(_:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped))
        addGestureRecognizer(tapGesture)
    }
    
    func addingViews() {
        self.contentView.addSubview(borderView)
        self.borderView.addSubview(stackView)
    }
    
    func configureConstraints() {
        self.borderView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.borderView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            self.borderView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            self.borderView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            self.borderView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
            
            self.stackView.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: 20),
            self.stackView.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor, constant: 20),
            self.stackView.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -20),
            self.stackView.bottomAnchor.constraint(equalTo: self.borderView.bottomAnchor, constant: -20),
        ])
    }
    
    func configure(with cellType: CellType, currentTheme: Theme?) {
        self.currentTheme = currentTheme
        self.titleLabel.text = cellType.title
        var iconImage: UIImage?
        switch cellType {
        case .premium:
            iconImage = currentTheme?.type == .dark ? UIImage(named: "img_premium_star_dark") : UIImage(named: "img_premium_star_light")
            self.arrowImageView.image = currentTheme?.type == .dark ?
            UIImage(named: "right_arrows")?.withTintColor(.whiteColor, renderingMode: .alwaysOriginal) :
            UIImage(named: "right_arrows")?.withTintColor(.blackColor, renderingMode: .alwaysOriginal)
        case .account:
            iconImage = UIImage(named: "account_icon")
            self.arrowImageView.image = currentTheme?.type == .dark ?
            UIImage(named: "right_arrows")?.withTintColor(.whiteColor, renderingMode: .alwaysOriginal) :
            UIImage(named: "right_arrows")?.withTintColor(.blackColor, renderingMode: .alwaysOriginal)
        case .darkMode:
            iconImage = UIImage(named: "dark_mode_icon")
        case .manageDefaultBrowser:
            iconImage = UIImage(named: "manage_browser_icon")
        case .manageNotifications:
            iconImage = UIImage(named: "manage_notifications_icon")
        case .getInTouch:
            iconImage = UIImage(named: "get_in_touch_icon")
        case .shareFreespoke:
            iconImage = UIImage(named: "share_icon")
        case .logout:
            self.titleLabel.attributedText = NSAttributedString(string: cellType.title, attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
            self.titleLabel.textColor = .systemBlue
            self.iconImageView.isHidden = true
            self.arrowImageView.isHidden = true
            self.darkModeSwitch.isHidden = true
        case .adBlocker:
            break
        case .verifyEmail:
            break
        }
        self.iconImageView.image = iconImage
        switch cellType {
        case .premium, .account:
            self.arrowImageView.isHidden = false
            self.titleLabel.isHidden = false
            self.iconImageView.isHidden = false
            self.darkModeSwitch.isHidden = true
        case .darkMode:
            iconImageView.isHidden = false
            self.arrowImageView.isHidden = true
            self.titleLabel.isHidden = false
            self.darkModeSwitch.isHidden = false
        case .manageDefaultBrowser, .manageNotifications, .getInTouch, .shareFreespoke:
            self.iconImageView.isHidden = false
            self.titleLabel.isHidden = false
            self.arrowImageView.isHidden = true
            self.darkModeSwitch.isHidden = true
        case .logout:
            self.iconImageView.isHidden = true
            self.titleLabel.isHidden = false
            self.arrowImageView.isHidden = true
            self.darkModeSwitch.isHidden = true
        case .adBlocker:
            break
        case .verifyEmail:
            break
        }
        
        self.applyTheme()
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            self.titleLabel.textColor = (theme.type == .light) ? .blackColor : .white
        }
    }
    
    func setDarkModeSwich(isOn: Bool) {
        self.darkModeSwitch.isOn = isOn
    }
    
    @objc private func darkModeSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.darkModeSwitchClosure?(sender.isOn)
        } else {
            self.darkModeSwitchClosure?(!sender.isOn)
        }
    }
    
    @objc private func cellTapped() {
        self.tapClosure?()
    }
}
