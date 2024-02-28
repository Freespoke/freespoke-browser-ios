// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

enum ActivityIndicatorSize {
    case small
    case large
}

class BaseActivityIndicator: UIView {
    private var overlayView: UIView?
    private let viewWithIndicator = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    
    private var activityIndicatorSize: ActivityIndicatorSize = .large
    var activityIndicatorColor = UIColor.black
    
    private lazy var descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.backgroundColor = UIColor.clear
        lbl.textColor = activityIndicatorColor
        lbl.font = UIFont.sourceSansProFont(.semiBold, size: 14)
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 4
        return lbl
    }()
    
    init(activityIndicatorSize: ActivityIndicatorSize) {
        super.init(frame: .zero)
        self.activityIndicatorSize = activityIndicatorSize
        prepareUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareUI() {
        self.backgroundColor = UIColor.clear
        
        switch self.activityIndicatorSize {
        case .large:
            activityIndicator.style = .large
        case .small:
            activityIndicator.style = .medium
        }
        
        viewWithIndicator.backgroundColor = UIColor.clear
        viewWithIndicator.layer.cornerRadius = 8
    }
    
    func start(pinToView view: UIView, withText text: String? = nil, overlay: Bool = false) {
        guard self.superview == nil else { return self.activityIndicator.startAnimating() }
        view.addSubview(self)
        
        view.bringSubviewToFront(self)
        
        descriptionLabel.text = text
        activityIndicator.color = self.activityIndicatorColor
        self.translatesAutoresizingMaskIntoConstraints = false
        self.pinToView(view: view)
        if overlay {
            self.addOverlayView()
        }
        self.addSubview(self.viewWithIndicator)
        self.addSubview(self.descriptionLabel)
        self.viewWithIndicator.addSubview(self.activityIndicator)
        
        self.viewWithIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewWithIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            viewWithIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            viewWithIndicator.heightAnchor.constraint(equalToConstant: 90),
            viewWithIndicator.widthAnchor.constraint(equalToConstant: 90),
            
            activityIndicator.topAnchor.constraint(equalTo: self.viewWithIndicator.topAnchor, constant: 10),
            activityIndicator.leftAnchor.constraint(equalTo: self.viewWithIndicator.leftAnchor, constant: 10),
            activityIndicator.rightAnchor.constraint(equalTo: self.viewWithIndicator.rightAnchor, constant: -10),
            activityIndicator.bottomAnchor.constraint(equalTo: self.viewWithIndicator.bottomAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: self.viewWithIndicator.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 20),
            descriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        self.activityIndicator.startAnimating()
    }
    
    func stop(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.viewWithIndicator.removeFromSuperview()
            self?.descriptionLabel.text = ""
            self?.descriptionLabel.removeFromSuperview()
            self?.removeOverlayView()
            self?.removeFromSuperview()
            completion?()
        }
    }
}

// MARK: - Overlay View

extension BaseActivityIndicator {
    // MARK: Add Overlay View
    
    private func addOverlayView() {
        guard self.overlayView?.superview == nil else { return }
        
        let overlayView = UIView()
        overlayView.isUserInteractionEnabled = true
        overlayView.backgroundColor = .black.withAlphaComponent(0.65)
        
        self.overlayView = overlayView
        
        guard let overlayView = self.overlayView else { return }
        
        self.addSubview(overlayView)
        
        overlayView.pinToView(view: self)
        self.layoutIfNeeded()
    }
    
    private func removeOverlayView() {
        self.overlayView?.removeFromSuperview()
        self.overlayView = nil
    }
}
