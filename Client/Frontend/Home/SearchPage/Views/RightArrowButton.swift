// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

final class RightArrowButton: UIButton {
    
    private var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        return sv
    }()
    
    private lazy var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = DynamicFontHelper.defaultHelper.preferredFont(withTextStyle: .title1, size: 16)
        lbl.numberOfLines = 1
        lbl.text = self.title
        return lbl
    }()
    
    private lazy var imgIcon: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: self.imgName)
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    let title: String
    let imgName: String
    let shouldShowTitle: Bool
    
    init(title: String, imgName: String, shouldShowTitle: Bool) {
        self.title = title
        self.imgName = imgName
        self.shouldShowTitle = shouldShowTitle
        super.init(frame: .zero)
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareUI() {
        self.stackView.isUserInteractionEnabled = false
        self.lblTitle.isUserInteractionEnabled = false
        self.imgIcon.isUserInteractionEnabled = false
    }
    
    private func addingViews() {
        self.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.lblTitle)
        self.stackView.addArrangedSubview(self.imgIcon)
    }
    
    private func setupConstraints() {
        self.imgIcon.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.pinToView(view: self, withInsets: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
        
        NSLayoutConstraint.activate([
            self.imgIcon.widthAnchor.constraint(equalToConstant: 13),
            self.imgIcon.heightAnchor.constraint(equalToConstant: 13),
        ])
    }
    
    func applyTheme(theme: Theme) {
        let titleColor = theme.colors.neutralsGrey
        self.lblTitle.textColor = titleColor
        self.imgIcon.tintColor = titleColor
    }
}
