// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class HomepageTopHeaderView: UIView {
    // MARK: - Properties
    
    private lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.image = UIImage(named: "banner-light")
        img.layer.masksToBounds = true
        return img
    }()
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.addSubviews()
        self.addSubviewsConstraints()
    }
    
    func applyTheme(currentTheme: Theme) {
        switch currentTheme.type {
        case .light:
            self.imgView.image = UIImage(named: "banner-light")
        case .dark:
            self.imgView.image = UIImage(named: "banner-dark")
        }
    }
}

// MARK: - Add Subviews

extension HomepageTopHeaderView {
    private func addSubviews() {
        self.addSubview(self.imgView)
    }
    
    private func addSubviewsConstraints() {
        self.imgView.translatesAutoresizingMaskIntoConstraints = false
        self.imgView.pinToView(view: self)
        
        NSLayoutConstraint.activate([
            self.imgView.widthAnchor.constraint(equalToConstant: 160),
            self.imgView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}
