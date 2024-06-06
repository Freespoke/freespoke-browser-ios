// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared

final class ViewRecentlyCell: UICollectionViewCell, ReusableCell {
    
    private let btnAction: RightArrowButton = {
        let font = DynamicFontHelper.defaultHelper.preferredFont(withTextStyle: .title1, size: 14)
        let btn = RightArrowButton(title: "View Recently Visited", imgName: "imgArrowRight", shouldShowTitle: true)
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
    }
    
    private func addingViews() {
        self.contentView.addSubview(self.btnAction)
    }
    
    private func setupConstraints() {
        self.btnAction.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.btnAction.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 9),
            self.btnAction.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor, constant: 0),
            self.btnAction.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            self.btnAction.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -9)
        ])
    }
    
    @objc private func tappedOnBtnAction() {
        self.closureTappedOnBtnAction?(self.btnAction)
    }
    
    func applyTheme(theme: Theme) {
        self.btnAction.applyTheme(theme: theme)
    }
    
}
