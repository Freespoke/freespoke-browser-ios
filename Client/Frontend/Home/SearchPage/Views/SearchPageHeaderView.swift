// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

final class SearchPageHeaderView: UICollectionReusableView, ReusableCell {
    
    lazy var lblTitle: UILabel = .build { label in
        label.font = DynamicFontHelper.defaultHelper.preferredFont(withTextStyle: .title1, size: 16)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
    }
    
    private let btnAction: RightArrowButton = {
        let btn = RightArrowButton(title: "See All", imgName: "imgArrowRight", shouldShowTitle: true)
        return btn
    }()
    
    var closureTappedOnBtnAction: ((UIButton) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareUI()
        self.addingViews()
        self.setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareUI() {
        self.btnAction.addTarget(self, action: #selector(self.tappedOnBtnAction), for: .touchUpInside)
//        self.backgroundColor = .systemPink
//        self.btnAction.backgroundColor = .red
//        self.lblTitle.backgroundColor = .blue
    }
    
    private func addingViews() {
        self.addSubview(self.lblTitle)
        self.addSubview(self.btnAction)
    }
    
    private func setupConstraints() {
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.btnAction.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.lblTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.lblTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            self.lblTitle.trailingAnchor.constraint(lessThanOrEqualTo: self.btnAction.leadingAnchor, constant: -10),
            self.lblTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            
            self.btnAction.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.btnAction.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -0),
            self.btnAction.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        ])
    }
    
    func setData(dataModel: LabelButtonHeaderViewModel) {
        self.lblTitle.text = dataModel.title
        self.btnAction.isHidden = dataModel.isButtonHidden
        self.closureTappedOnBtnAction = dataModel.buttonAction
    }
    
    @objc private func tappedOnBtnAction() {
        self.closureTappedOnBtnAction?(self.btnAction)
    }
    
}

extension SearchPageHeaderView: ThemeApplicable {
    func applyTheme(theme: Theme) {
        let titleColor = theme.colors.neutralsGrey
        self.lblTitle.textColor = titleColor
        self.btnAction.applyTheme(theme: theme)
    }
}
