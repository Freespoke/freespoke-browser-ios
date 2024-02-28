// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

// MARK: - LogoutCell

class LogoutCell: UITableViewCell {
    static let identifier = String(describing: type(of: LogoutCell.self))
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.sourceSansProFont(.semiBold, size: 19)
        label.textAlignment = .center
        label.attributedText = NSAttributedString(string: "Log Out", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        return label
    }()
    
    var tapClosure: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.prepareUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareUI() {
        contentView.addSubview(self.titleLabel)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            self.titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.titleLabel.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped))
        addGestureRecognizer(tapGesture)
    }
    
    func configureCell(textColor: UIColor) {
        self.titleLabel.textColor = textColor
    }
    
    @objc private func cellTapped() {
        self.tapClosure?()
    }
}
