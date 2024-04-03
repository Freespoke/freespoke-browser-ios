// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

class EmailTextField: CustomTextField {
    init() {
        super.init()
        self.commonInit()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInit() {
        self.returnKeyType = UIReturnKeyType.default
        self.spellCheckingType = .no
        self.autocapitalizationType = .none
        self.smartQuotesType = .no
        self.textContentType = .emailAddress
        self.autocorrectionType = .no
    }
}
