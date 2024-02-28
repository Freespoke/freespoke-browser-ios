// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

final class AuthOrView: UIView {
    private lazy var leftLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .whiteColor
        return view
    }()
    
    private lazy var lblOr: UILabel = {
        let lbl = UILabel()
        lbl.text = "OR"
        lbl.textColor = self.currentTheme?.type == .dark ? UIColor.white : UIColor.blackColor
        lbl.textAlignment = .center
        lbl.font = .sourceSansProFont(.regular, size: 12)
        return lbl
    }()
    
    private lazy var rightLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .whiteColor
        return view
    }()
    
    private var currentTheme: Theme?
    
    required init(currentTheme: Theme?) {
        self.currentTheme = currentTheme
        super.init(frame: .zero)
        addingViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addingViews() {
        self.addSubview(leftLineView)
        self.addSubview(lblOr)
        self.addSubview(rightLineView)
    }
    
    private func setupConstraints() {
        rightLineView.translatesAutoresizingMaskIntoConstraints = false
        lblOr.translatesAutoresizingMaskIntoConstraints = false
        leftLineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lblOr.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            lblOr.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            lblOr.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            lblOr.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            leftLineView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            leftLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            leftLineView.trailingAnchor.constraint(equalTo: self.lblOr.leadingAnchor, constant: -10),
            leftLineView.heightAnchor.constraint(equalToConstant: 1),
            
            rightLineView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            rightLineView.leadingAnchor.constraint(equalTo: self.lblOr.trailingAnchor, constant: 10),
            rightLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            rightLineView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}
