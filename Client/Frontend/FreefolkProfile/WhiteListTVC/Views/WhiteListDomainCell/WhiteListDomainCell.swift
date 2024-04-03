// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared

final class WhiteListDomainCell: UITableViewCell {
    static let reuseIdentifier = String(describing: type(of: WhiteListDomainCell.self))
    
    private let borderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.whiteColor.cgColor
        return view
    }()
    
    private let lblDomain: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.sourceSansProFont(.regular, size: 14)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let btnRemoveDomain: UIButton = {
        let btn = UIButton()
        let image = UIImage(named: "close-all-text")?.withTintColor(UIColor.fxOffWhite1, renderingMode: .alwaysOriginal)
        btn.setImage(image, for: .normal)
        btn.setSizeToView(width: 40)
        return btn
    }()
    
    private var currentTheme: Theme?
    
    var closureTappedOnBtnRemoveDomain: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareUI() {
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.btnRemoveDomain.addTarget(self, action: #selector(self.tappedOnBtnRemoveDomain), for: .touchUpInside)
    }
    
    private func addingViews() {
        self.contentView.addSubview(self.borderView)
        self.borderView.addSubview(self.lblDomain)
        self.borderView.addSubview(self.btnRemoveDomain)
    }
    
    private func setupConstraints() {
        self.lblDomain.translatesAutoresizingMaskIntoConstraints = false
        self.btnRemoveDomain.translatesAutoresizingMaskIntoConstraints = false
        
        self.borderView.pinToView(view: self.contentView, withInsets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
        
        NSLayoutConstraint.activate([
            self.lblDomain.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: 10),
            self.lblDomain.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor, constant: 12),
            self.lblDomain.trailingAnchor.constraint(lessThanOrEqualTo: self.btnRemoveDomain.trailingAnchor, constant: -12),
            self.lblDomain.bottomAnchor.constraint(equalTo: self.borderView.bottomAnchor, constant: -10),
            
            self.btnRemoveDomain.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: 0),
            self.btnRemoveDomain.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: 0),
            self.btnRemoveDomain.bottomAnchor.constraint(equalTo: self.borderView.bottomAnchor, constant: 0)
        ])
    }
    
    @objc private func tappedOnBtnRemoveDomain() {
        self.closureTappedOnBtnRemoveDomain?()
    }
    
    func setDomain(domain: String) {
        self.lblDomain.text = domain
    }
    
    func updateTheme(currentTheme: Theme?) {
        self.currentTheme = currentTheme
        self.applyTheme()
    }
    
    private func applyTheme() {
        if let theme = currentTheme {
            self.borderView.layer.borderColor = (theme.type == .light) ? UIColor.whiteColor.cgColor : UIColor.blackColor.cgColor
        }
    }
}
