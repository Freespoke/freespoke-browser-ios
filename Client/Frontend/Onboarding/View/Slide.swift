// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

protocol SlideDelegate: class {
    func didSelectBack()
    func didSelectNext()
    func didSelectSetDefaultBrowser()
}

class Slide: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblBottom: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnSetDefault: UIButton!
    
    weak var delegate: SlideDelegate?
    
    @IBAction func btnNext(_ sender: Any) {
        delegate?.didSelectNext()
    }
    
    @IBAction func btnSetDefault(_ sender: Any) {
        delegate?.didSelectSetDefaultBrowser()
    }
}
