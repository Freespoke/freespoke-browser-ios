// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class StorySummaryTopView: UIView {
    // MARK: - Properties
    
    private let imageView: UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.layer.masksToBounds = true
        img.image = UIImage.templateImageNamed(ImageIdentifiers.imgAiGeneratedIcon)
        img.tintColor = UIColor.neutralsGray02
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    private var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textColor = UIColor.neutralsGray02
        lbl.font = UIFont.sourceSansProFont(.regular, size: 14)
        lbl.text = "Freespoke AI Summary"
        return lbl
    }()
    
    private var lblSubTitle: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textColor = UIColor.neutralsGray02
        lbl.font = UIFont.sourceSansProFont(.semiBold, size: 14)
        return lbl
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
        
        self.backgroundColor = UIColor.clear
    }
    
    func applyTheme(currentTheme: Theme) {
        switch currentTheme.type {
        case .light:
            self.backgroundColor = UIColor.clear
            self.lblTitle.textColor = UIColor.neutralsGray02
            self.lblSubTitle.textColor = UIColor.neutralsGray02
            self.imageView.tintColor = UIColor.neutralsGray02
        case .dark:
            self.backgroundColor = UIColor.clear
            self.lblTitle.textColor = UIColor.neutralsGray06
            self.lblSubTitle.textColor = UIColor.neutralsGray06
            self.imageView.tintColor = UIColor.neutralsGray06
        }
    }
    
    func configure(sources: [String]) {
        if !sources.isEmpty {
            let sourcesText = self.formatSources(sources: sources)
            self.lblTitle.text = "Freespoke AI Summary of"
            self.lblSubTitle.text = "\(sourcesText)"
        } else {
            self.lblTitle.text = "Freespoke AI Summary"
            self.lblSubTitle.text = nil
        }
    }
    
    private func formatSources(sources: [String]) -> String {
        switch sources.count {
        case 0:
            return ""
        case 1:
            return sources[0]
        case 2:
            return "\(sources[0]) and \(sources[1])"
        default:
            let allButLast = sources.dropLast().joined(separator: ", ")
            return "\(allButLast), and \(sources.last!)"
        }
    }
}

// MARK: - Add Subviews

extension StorySummaryTopView {
    private func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.lblTitle)
        self.addSubview(self.lblSubTitle)
    }
    
    private func addSubviewsConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.lblTitle.translatesAutoresizingMaskIntoConstraints = false
        self.lblSubTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            self.imageView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -9),
            self.imageView.heightAnchor.constraint(equalToConstant: 14),
            self.imageView.widthAnchor.constraint(equalToConstant: 14),
            
            self.lblTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.lblTitle.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 5),
            self.lblTitle.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: 0),
            
            self.lblSubTitle.topAnchor.constraint(equalTo: self.lblTitle.bottomAnchor, constant: 0),
            self.lblSubTitle.leadingAnchor.constraint(equalTo: self.lblTitle.leadingAnchor, constant: 0),
            self.lblSubTitle.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: 0),
            self.lblSubTitle.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: 0)
        ])
    }
}
