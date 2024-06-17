// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class HomePageMoreNewsCardView: UIView {
    // MARK: - Properties
    
    private var topLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.neutralsGray05
        return view
    }()
    
    private var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.neutralsGray05
        return view
    }()
    
    private var moreNewsButton: MoreNewsButton = {
        let btn = MoreNewsButton()
        return btn
    }()
    
    var didTapMoreNewsButtonClosure: (() -> Void)?
    
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
        
        self.moreNewsButton.addTarget(self, action: #selector(self.didTapMoreNewsButton), for: .touchUpInside)
    }
    
    func applyTheme(currentTheme: Theme) {
        switch currentTheme.type {
        case .light:
            self.topLineView.backgroundColor = UIColor.neutralsGray05
            self.bottomLineView.backgroundColor = UIColor.neutralsGray05
        case .dark:
            self.topLineView.backgroundColor = UIColor.neutralsGray01
            self.bottomLineView.backgroundColor = UIColor.neutralsGray01
        }
    }
    
    @objc private func didTapMoreNewsButton() {
        self.didTapMoreNewsButtonClosure?()
    }
}

// MARK: - Add Subviews

extension HomePageMoreNewsCardView {
    private func addSubviews() {
        self.addSubview(self.topLineView)
        self.addSubview(self.moreNewsButton)
        self.addSubview(self.bottomLineView)
    }
    
    private func addSubviewsConstraints() {
        self.topLineView.translatesAutoresizingMaskIntoConstraints = false
        self.moreNewsButton.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topLineView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.topLineView.heightAnchor.constraint(equalToConstant: 1),
            self.topLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.topLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.moreNewsButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.moreNewsButton.widthAnchor.constraint(equalToConstant: 116),
            self.moreNewsButton.heightAnchor.constraint(equalToConstant: 34),
            self.moreNewsButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.moreNewsButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            
            self.bottomLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            self.bottomLineView.heightAnchor.constraint(equalToConstant: 1),
            self.bottomLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.bottomLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}
