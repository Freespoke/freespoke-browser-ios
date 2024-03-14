// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

// MARK: - VerifyEmailCell
class VerifyEmailCell: UITableViewCell {
    static let identifier = String(describing: type(of: VerifyEmailCell.self))
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "img_info_icon")
        return imageView
    }()
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.textColor = UIColor.charcoalGrayColor
        lbl.font = UIFont.sourceSansProFont(.semiBold, size: 16)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    
    private var lblSubtitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.textColor = UIColor.gunmetalGrayColor
        lbl.font = UIFont.sourceSansProFont(.regular, size: 16)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    
    private var labelsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 5
        return sv
    }()
    
    private var borderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 4.0
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    var currentTheme: Theme?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addingViews()
        self.configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addingViews() {
        self.borderView.addSubview(self.iconImageView)
        self.labelsStackView.addArrangedSubview(self.lblTitle)
        self.labelsStackView.addArrangedSubview(self.lblSubtitle)
        self.borderView.addSubview(self.labelsStackView)
        self.contentView.addSubview(self.borderView)
    }
    
    private func configureConstraints() {
        self.borderView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.borderView.pinToView(view: self.contentView, withInsets: UIEdgeInsets(top: 10,
                                                                                   left: 20,
                                                                                   bottom: 10,
                                                                                   right: 20))
        
        NSLayoutConstraint.activate([
            self.iconImageView.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: 12),
            self.iconImageView.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor, constant: 12),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 20),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 20),
            
            self.labelsStackView.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: 12),
            self.labelsStackView.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
            self.labelsStackView.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -12),
            self.labelsStackView.bottomAnchor.constraint(equalTo: self.borderView.bottomAnchor, constant: -12),
            self.labelsStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
    }
    
    func configure(title: String, subtitle: String, currentTheme: Theme?) {
        self.lblTitle.text = title
        self.lblSubtitle.text = subtitle
        
        self.currentTheme = currentTheme
        self.applyTheme()
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            self.backgroundColor = (theme.type == .light) ? .gray7 : .black
            self.borderView.backgroundColor = (theme.type == .light) ? .white : .black
            self.lblTitle.textColor = (theme.type == .light) ? .charcoalGrayColor : .white
            self.lblSubtitle.textColor = (theme.type == .light) ? .gunmetalGrayColor : .white
        }
    }
}
