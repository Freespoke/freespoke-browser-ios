// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class BreakingNewsCellBottomView: UIView {
    // MARK: - Properties
    
    private var biasStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.spacing = 4
        sv.layer.masksToBounds = true
        sv.clipsToBounds = false
        return sv
    }()
    
    private let biasImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let lblBias: UILabel = {
        let label = UILabel()
        label.font = UIFont.sourceSansProFont(.bold, size: 12)
        label.textColor = UIColor.neutralsGray02
        return label
    }()
    
    private let lblPublishedDate: UILabel = {
        let label = UILabel()
        label.font = UIFont.sourceSansProFont(.regular, size: 14)
        label.textColor = UIColor.neutralsGray02
        return label
    }()
    
    private var bias: BiasType?
    
    // MARK: - Initializers

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
    
    // MARK: - Setup Methods

    private func addSubviews() {
        self.addSubview(self.biasStackView)
        self.addSubview(self.lblPublishedDate)
    }

    private func addSubviewsConstraints() {
        self.biasImageView.translatesAutoresizingMaskIntoConstraints = false
        self.biasStackView.translatesAutoresizingMaskIntoConstraints = false
        self.lblPublishedDate.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.biasImageView.heightAnchor.constraint(equalToConstant: 12),
            self.biasImageView.widthAnchor.constraint(equalToConstant: 12),
            
            self.biasStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            self.biasStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            self.biasStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            
            self.lblPublishedDate.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            self.lblPublishedDate.centerYAnchor.constraint(equalTo: self.biasStackView.centerYAnchor, constant: 0),
            self.lblPublishedDate.leadingAnchor.constraint(greaterThanOrEqualTo: self.biasStackView.trailingAnchor, constant: 10)
        ])
    }
    
    // MARK: - Configuration Method

    func configure(with bias: BiasType?, dateConvertedForDisplay: String?) {
        self.bias = bias
        
        self.biasStackView.arrangedSubviews.forEach({ [weak self] in
            self?.biasStackView.removeArrangedSubview($0)
            if $0.superview != nil {
                $0.removeFromSuperview()
            }
            self?.layoutIfNeeded()
        })
        
        self.lblPublishedDate.text = dateConvertedForDisplay
        
        self.lblBias.text = bias?.title
        self.biasImageView.image = bias?.iconImage
        
        if self.biasImageView.image != nil {
            self.biasStackView.addArrangedSubview(self.biasImageView)
        }
        
        self.biasStackView.addArrangedSubview(self.lblBias)
    }
    
    func applyTheme(currentTheme: Theme) {
        switch currentTheme.type {
        case .light:
            self.backgroundColor = UIColor.white
            self.lblPublishedDate.textColor = UIColor.neutralsGray02
            
            if let bias = self.bias {
                switch bias {
                case .left:
                    self.lblBias.textColor = UIColor.brand600BlueLead
                    self.biasImageView.tintColor = UIColor.brand600BlueLead
                case .middle:
                    self.lblBias.textColor = UIColor.neutralsGray01
                    self.biasImageView.tintColor = UIColor.neutralsGray01
                case .right:
                    self.lblBias.textColor = UIColor.crimsonRed
                    self.biasImageView.tintColor = UIColor.crimsonRed
                }
            }
            
        case .dark:
            self.backgroundColor = UIColor.clear
            self.lblPublishedDate.textColor = UIColor.neutralsGray06
            
            if let bias = self.bias {
                switch bias {
                case .left:
                    self.lblBias.textColor = UIColor.brand600BlueLead
                    self.biasImageView.tintColor = UIColor.brand600BlueLead
                case .middle:
                    self.lblBias.textColor = UIColor.white
                    self.biasImageView.tintColor = UIColor.white
                case .right:
                    self.lblBias.textColor = UIColor.crimsonRed
                    self.biasImageView.tintColor = UIColor.crimsonRed
                }
            }
        }
    }
}
