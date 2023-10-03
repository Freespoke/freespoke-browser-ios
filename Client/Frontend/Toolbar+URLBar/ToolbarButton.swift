// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class ToolbarButton: UIButton {
    // MARK: - Variables

    var selectedTintColor: UIColor!
    var unselectedTintColor: UIColor!
    var disabledTintColor = UIColor.Photon.Grey50
    
    var isHome = false

    // Optionally can associate a separator line that hide/shows along with the button
    weak var separatorLine: UIView?

    override open var isHighlighted: Bool {
        didSet {
            if self.tag == 2 && isHome {
                switch LegacyThemeManager.instance.currentName {
                case .normal:
                    self.tintColor = UIColor.redHomeToolbar
                    
                case .dark:
                    self.tintColor = UIColor.white
                }
            }
            else {
                self.tintColor = isHighlighted ? selectedTintColor : unselectedTintColor
            }
        }
    }

    override open var isEnabled: Bool {
        didSet {
            self.tintColor = isEnabled ? unselectedTintColor : disabledTintColor
        }
    }

    override var tintColor: UIColor! {
        didSet {
            imageView?.tintColor = self.tintColor
            setTitleColor(tintColor, for: .normal)
        }
    }

    override var isHidden: Bool {
        didSet {
            separatorLine?.isHidden = isHidden
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        adjustsImageWhenHighlighted = false
        titleLabel?.font = UIFont(name: "SourceSansPro-SemiBold", size: 10)
        selectedTintColor = tintColor
        unselectedTintColor = tintColor
        imageView?.contentMode = .scaleAspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Theme protocols

extension ToolbarButton: NotificationThemeable {
    func applyTheme() {
        selectedTintColor = UIColor.legacyTheme.toolbarButton.selectedTint
        //disabledTintColor = UIColor.legacyTheme.toolbarButton.disabledTint
        disabledTintColor = UIColor.Photon.Grey50
        //unselectedTintColor = UIColor.legacyTheme.browser.tint
        
        switch LegacyThemeManager.instance.currentName {
        case .normal:
            unselectedTintColor = UIColor.legacyTheme.browser.tint
            
        case .dark:
            unselectedTintColor = UIColor.inactiveToolbar
        }
        
        if tag == 2 && isHome {
            switch LegacyThemeManager.instance.currentName {
            case .normal:
                tintColor = UIColor.redHomeToolbar
                
            case .dark:
                tintColor = UIColor.white
            }
        }
        else {
            tintColor = isEnabled ? unselectedTintColor : disabledTintColor
        }
        
        if tag == 2 {
            switch LegacyThemeManager.instance.currentName {
            case .normal:
                selectedTintColor = UIColor.redHomeToolbar
                
            case .dark:
                selectedTintColor = UIColor.white
            }
        }
        
        imageView?.tintColor = tintColor
        titleLabel?.font = UIFont(name: "SourceSansPro-SemiBold", size: 10)
        setTitleColor(selectedTintColor, for: .highlighted)
        setTitleColor(tintColor, for: .normal)
    }
}
