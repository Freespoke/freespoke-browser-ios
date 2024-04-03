// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared

final class WhiteListBtnCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: type(of: WhiteListBtnCell.self))
    
    private let btnAction: BaseButton = {
        let btn = BaseButton(style: .greenStyle(currentTheme: nil))
        return btn
    }()
    
    private var currentTheme: Theme? {
        didSet {
            self.btnAction.setStyle(style: .greenStyle(currentTheme: self.currentTheme))
        }
    }
    
    var closureTappedonBtnAction: (() -> Void)?
    
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
        self.btnAction.addTarget(self, action: #selector(self.tappedonBtnAction), for: .touchUpInside)
    }
    
    private func addingViews() {
        self.contentView.addSubview(self.btnAction)
    }
    
    private func setupConstraints() {
        self.btnAction.pinToView(view: self.contentView, withInsets: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
    }
    
    func setData(currentTheme: Theme?, title: String) {
        self.currentTheme = currentTheme
        self.btnAction.setTitle(title, for: .normal)
    }
    
    @objc private func tappedonBtnAction() {
        self.closureTappedonBtnAction?()
    }
    
    func updateButtonState(isEnteredTextDomain: Bool) {
        self.btnAction.isEnabled = isEnteredTextDomain
    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        print("TEST: Hit test !!!!")
//        
//        let convertedPoint = self.convert(point, to: self.btnAction)
//        if self.btnAction.point(inside: convertedPoint, with: event) {
//            print("TEST: Hit test buttonAction contain point !!!!")
//            return self.btnAction
//        } else {
//            return super.hitTest(point, with: event)
//        }
//    }
}
