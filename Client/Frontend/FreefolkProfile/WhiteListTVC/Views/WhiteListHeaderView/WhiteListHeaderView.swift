// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

final class WhiteListHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = String(describing: type(of: WhiteListHeaderView.self))
    
    private let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.sourceSansProFont(.semiBold, size: 24)
//        lbl.textColor = UIColor()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        
        return lbl
    }()
    
    private let lblBody: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.sourceSansProFont(.regular, size: 16)
//        lbl.textColor = UIColor()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
    }()
    
    private var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        return sv
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareUI() {
        
    }
    
    private func addingViews() {
        self.contentView.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.lblTitle)
        self.stackView.addArrangedSubview(self.lblBody)
    }
    
    private func setupConstraints() {
        self.stackView.pinToView(view: self.contentView, withInsets: UIEdgeInsets(top: 0, left: 40, bottom: 20, right: 40))
    }
    
    func setData(title: String? = nil, body: String? = nil) {
        self.lblTitle.text = title?.uppercased()
        self.lblBody.text = body
        self.lblBody.isHidden = (body == nil)
    }
}
