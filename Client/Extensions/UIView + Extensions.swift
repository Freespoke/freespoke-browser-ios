// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

extension UIView {
    func pinToView(view: UIView, safeAreaLayout: Bool = false, withInsets insets: UIEdgeInsets? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if safeAreaLayout {
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                              constant: insets?.left ?? 0),
                self.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                               constant: -(insets?.right ?? 0)),
                self.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                          constant: insets?.top ?? 0),
                self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                             constant: -(insets?.bottom ?? 0))
            ])
        } else {
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets?.left ?? 0),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(insets?.right ?? 0)),
                self.topAnchor.constraint(equalTo: view.topAnchor, constant: insets?.top ?? 0),
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(insets?.bottom ?? 0))
            ])
        }
    }
    
    func pinToView(view: UIView, withInsets insets: UIEdgeInsets) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ])
    }

    func setSizeToView(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if let width = width { self.widthAnchor.constraint(equalToConstant: width).isActive = true }
        if let height = height { self.heightAnchor.constraint(equalToConstant: height).isActive = true }
    }
    
    /** Get the Parent View Controller */
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}

// MARK: - Dashed Border

extension UIView {
    func addDashedBorder(color: UIColor, lineDashPattern: [NSNumber], lineWidth: CGFloat, cornerRadius: CGFloat) {
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = lineDashPattern
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: cornerRadius).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
}

// MARK: - Gradient

extension UIView {
    // MARK: Gradient to UIView

    enum GradientDirection {
        case vertical
        case horizontal
        case verticalLeftToRight
        
        var startingPoint: CGPoint {
            switch self {
            case .vertical, .horizontal, .verticalLeftToRight:
                return CGPoint.topLeft
            }
        }
        
        var endingPoint: CGPoint {
            switch self {
            case .vertical:
                return CGPoint.bottomLeft
            case .horizontal:
                return CGPoint.topRight
            case .verticalLeftToRight:
                return CGPoint.bottomRight
            }
        }
    }
    
    func setGradient(locations: [NSNumber], colors: [CGColor], startPoint: CGPoint? = nil, endPoint: CGPoint? = nil) {
        let gradientLayer = self.layer.sublayers?
            .first(where: { $0 is CAGradientLayer }) as? CAGradientLayer ?? CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        if let startPoint = startPoint {
            gradientLayer.startPoint = startPoint
        }
        if let endPoint = endPoint {
            gradientLayer.endPoint = endPoint
        }
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setGradient(gradientDirection direction: GradientDirection, colors: [CGColor]) {
        let gradientLayer = self.layer.sublayers?
            .first(where: { $0 is CAGradientLayer }) as? CAGradientLayer ?? CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = direction.startingPoint
        gradientLayer.endPoint = direction.endingPoint
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setGradientBorder(gradientDirection: GradientDirection, colors: [CGColor], width: CGFloat = 1) {
        let gradientLayer = self.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer ?? CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        
        let shape = CAShapeLayer()
        shape.lineWidth = width
        shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        
        gradientLayer.mask = shape
        
        if self.layer.sublayers?.contains(gradientLayer) != true {
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}

