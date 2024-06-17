// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

// MARK: - PremiumCell
class PremiumCell: UITableViewCell {
    static let identifier = String(describing: type(of: PremiumCell.self))
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleView: ProfileCellTitleView = {
        let view = ProfileCellTitleView()
        return view
    }()
    
    private let warningIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "right_arrows")
        return imageView
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
                                                       titleView,
                                                       arrowImageView])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    private var borderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.whiteColor.cgColor
        view.layer.cornerRadius = 4.0
        view.layer.masksToBounds = true
        return view
    }()
    
    var currentTheme: Theme?
    
    var cellTappedClosure: (() -> Void)?
    var warningButtonTappedClosure: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.prepareUI()
        self.addingViews()
        self.configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleView.warningButtonTappedClosure = nil
    }
    
    func prepareUI() {
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
            
            self.stackView.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: 7),
            self.stackView.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor, constant: 20),
            self.stackView.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -20),
            self.stackView.bottomAnchor.constraint(equalTo: self.borderView.bottomAnchor, constant: -7),
            self.stackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configure(title: String, currentTheme: Theme?, shouldDisplayWarningView: Bool) {
        self.titleView.titleLabel.text = title
        self.currentTheme = currentTheme
        if shouldDisplayWarningView {
            self.titleView.showWarningView()
        } else {
            self.titleView.hideWarningView()
        }
        self.iconImageView.image = currentTheme?.type == .dark ? UIImage(named: "img_premium_star_dark") : UIImage(named: "img_premium_star_light")
        
        self.arrowImageView.image = currentTheme?.type == .dark ?
        UIImage(named: "right_arrows")?.withTintColor(.whiteColor, renderingMode: .alwaysOriginal) :
        UIImage(named: "right_arrows")?.withTintColor(.blackColor, renderingMode: .alwaysOriginal)
        self.titleView.warningButtonTappedClosure = { [weak self] in
            self?.warningButtonTappedClosure?()
        }
        
        self.applyTheme()
    }
    
    func showWarningView() {
        self.titleView.showWarningView()
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            self.backgroundColor = (theme.type == .light) ? .neutralsGray07 : .clear
            self.titleView.titleLabel.textColor = (theme.type == .light) ? .blackColor : .white
            self.borderView.layer.borderColor = (theme.type == .light) ? UIColor.whiteColor.cgColor : UIColor.blackColor.cgColor
        }
    }
    
    @objc private func cellTapped() {
        self.cellTappedClosure?()
    }
}

// MARK: - Hit Test

extension PremiumCell {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let convertedPoint = self.convert(point, to: self.titleView.warningButton)
        return self.titleView.warningButton.point(inside: convertedPoint, with: event) ? self.titleView.warningButton : super.hitTest(point, with: event)
    }
}
