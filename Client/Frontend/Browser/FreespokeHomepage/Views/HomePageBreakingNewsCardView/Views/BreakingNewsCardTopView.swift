// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class BreakingNewsCardTopView: UIView {
    // MARK: - Properties
    
    private var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.neutralsGray01
        return view
    }()
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "BREAKING NEWS"
        lbl.textColor = UIColor.neutralsGray01
        lbl.font = UIFont.sourceSansProFont(.bold, size: 14)
        return lbl
    }()
    
    private var btnViewAll: UnderlinedButton = {
        let btn = UnderlinedButton()
        btn.setTitle("View All", for: .normal)
        btn.setTitleColor(UIColor.neutralsGray01, for: .normal)
        btn.titleLabel?.font = UIFont.sourceSansProFont(.regular, size: 14)
        return btn
    }()
    
    private var lineView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.neutralsGray01
        return view
    }()
    
    var btnViewAllDidTapClosure: (() -> Void)?
    
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
        
        self.backgroundColor = UIColor.neutralsGray06
        self.btnViewAll.addTarget(self, action: #selector(self.didTapViewAllButton), for: .touchUpInside)
    }
    
    func applyTheme(currentTheme: Theme) {
        switch currentTheme.type {
        case .light:
            self.backgroundColor = UIColor.neutralsGray06
            self.lineView.backgroundColor = UIColor.neutralsGray05
            self.lblTitle.textColor = UIColor.neutralsGray01
            self.btnViewAll.setTitleColor(UIColor.neutralsGray01, for: .normal)
            self.lineView1.backgroundColor = UIColor.neutralsGray05
        case .dark:
            self.backgroundColor = UIColor.clear
            self.lineView.backgroundColor = UIColor.neutralsGray01
            self.lblTitle.textColor = UIColor.white
            self.btnViewAll.setTitleColor(UIColor.white, for: .normal)
            self.lineView1.backgroundColor = UIColor.neutralsGray01
        }
    }
}

// MARK: - Add Subviews

extension BreakingNewsCardTopView {
    private func addSubviews() {
        self.addSubview(self.lineView)
        self.addSubview(self.lblTitle)
        self.addSubview(self.btnViewAll)
        self.addSubview(self.lineView1)
    }
    
    private func addSubviewsConstraints() {
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.btnViewAll.translatesAutoresizingMaskIntoConstraints = false
        self.lineView1.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.lineView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.lineView.heightAnchor.constraint(equalToConstant: 1),
            self.lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.lblTitle.topAnchor.constraint(equalTo: self.lineView.bottomAnchor, constant: 13),
            self.lblTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            self.btnViewAll.leadingAnchor.constraint(greaterThanOrEqualTo: self.lblTitle.trailingAnchor, constant: 10),
            self.btnViewAll.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.btnViewAll.centerYAnchor.constraint(equalTo: self.lblTitle.centerYAnchor, constant: 0),
            
            self.lineView1.topAnchor.constraint(equalTo: self.lblTitle.bottomAnchor, constant: 13),
            self.lineView1.heightAnchor.constraint(equalToConstant: 1),
            self.lineView1.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.lineView1.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.lineView1.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    @objc private func didTapViewAllButton() {
        self.btnViewAllDidTapClosure?()
    }
}
