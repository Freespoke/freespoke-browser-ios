// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Storage
import Shared
import Foundation
import Dispatch

protocol MenuControllerDelegate: class {
    func didSelectOption(curCellType: MenuCellType)
    func didSelectSocial(socialType: SocialType)
}

class MenuController: UIViewController {
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var imgViewLogo: UIImageView!
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var btnLinkedin: UIButton!
    @IBOutlet weak var btnInstagram: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var constViewSocialsWidth: NSLayoutConstraint!
    
    var arrOptions  = [MenuCellType]()
    var arrImageOptions  = [MenuCellImageType]()
    weak var delegate: MenuControllerDelegate?
    
    var currentTheme: Theme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        setupLayouts()
    }
    
    private func setupUI() {
        arrOptions.append(contentsOf: [.addAsDefault, .shareFreespoke, .freespokeBlog, .ourNewsletters, .getInTouch, .appSettings, .bookmars])
        arrImageOptions.append(contentsOf: [.addAsDefault, .shareFreespoke, .freespokeBlog, .ourNewsletters, .getInTouch, .appSettings, .bookmars])
        
        applyTheme()
    }
    
    private func setupLayouts() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            constViewSocialsWidth.constant = 360
        }
        else {
            let size = UIScreen.main.bounds.size.width - 64
            
            if size > 360 {
                constViewSocialsWidth.constant = 360
            }
            else {
                constViewSocialsWidth.constant = size
            }
        }
        
        btnTwitter.layer.cornerRadius     = btnTwitter.bounds.size.height / 2
        btnTwitter.layer.masksToBounds    = true
        
        btnLinkedin.layer.cornerRadius     = btnLinkedin.bounds.size.height / 2
        btnLinkedin.layer.masksToBounds    = true
        
        btnInstagram.layer.cornerRadius     = btnInstagram.bounds.size.height / 2
        btnInstagram.layer.masksToBounds    = true
        
        btnFacebook.layer.cornerRadius     = btnFacebook.bounds.size.height / 2
        btnFacebook.layer.masksToBounds    = true
    }
    
    private func dismissScreen() {
        transitionVc(duration: 0.0, type: .fromLeft)
        
        navigationController?.popViewController(animated: false)
        //dismiss(animated: false)
    }
    
    func applyTheme() {
        if let theme = currentTheme {
            //viewBackground.backgroundColor = theme.colors.layer1
            
            switch theme.type {
            case .dark:
                viewBackground.backgroundColor = .darkBackground
                
                btnTwitter.backgroundColor = .blackColor
                btnLinkedin.backgroundColor = .blackColor
                btnInstagram.backgroundColor = .blackColor
                btnFacebook.backgroundColor = .blackColor
                btnTwitter.tintColor = .white
                btnLinkedin.tintColor = .white
                btnInstagram.tintColor = .white
                btnFacebook.tintColor = .white
                
                btnBack.tintColor = .white
                
                imgViewLogo.image = UIImage(named: "Freespoke Torch - Dark Mode")!
                
            case .light:
                let color = UIColor(colorString: "EDF0F5")
                
                viewBackground.backgroundColor = theme.colors.layer1
                
                btnTwitter.backgroundColor = color
                btnLinkedin.backgroundColor = color
                btnInstagram.backgroundColor = color
                btnFacebook.backgroundColor = color
                btnTwitter.tintColor = .blackColor
                btnLinkedin.tintColor = .blackColor
                btnInstagram.tintColor = .blackColor
                btnFacebook.tintColor = .blackColor
                
                btnBack.tintColor = .blackColor
                
                imgViewLogo.image = UIImage(named: "Freespoke Torch - Light Mode")!
            }
        }
    }
    
    private func shareFresspoke() {
        guard let url = URL(string: Constants.freespokeURL.rawValue) else { return }
        
        let helper = ShareExtensionHelper(url: url, tab: nil)
        let controller = helper.createActivityViewController({ completed, activityType in
        })
        
        if let popoverPresentationController = controller.popoverPresentationController {
            let cellRect = tblView.rectForRow(at: IndexPath(row: 1, section: 0))
            
            popoverPresentationController.sourceView = tblView
            popoverPresentationController.sourceRect = cellRect
            popoverPresentationController.permittedArrowDirections = [.up, .down]
            //popoverPresentationController.delegate = self
        }
        
        presentWithModalDismissIfNeeded(controller, animated: true)
    }
    
    @IBAction func btnTwitter(_ sender: Any) {
        delegate?.didSelectSocial(socialType: .twitter)
        
        dismissScreen()
    }
    
    @IBAction func btnLinkedin(_ sender: Any) {
        delegate?.didSelectSocial(socialType: .linkedin)
        
        dismissScreen()
    }
    
    @IBAction func btnInstagram(_ sender: Any) {
        delegate?.didSelectSocial(socialType: .instagram)
        
        dismissScreen()
    }
    
    @IBAction func btnFacebook(_ sender: Any) {
        delegate?.didSelectSocial(socialType: .facebook)
        
        dismissScreen()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        dismissScreen()
    }
}

// MARK: - UITableViewDataSource Methods

extension MenuController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell
        
        if indexPath.row < arrOptions.count {
            cell.delegate   = self
            cell.theme      = currentTheme
            
            cell.setupCell(cellType: arrOptions[indexPath.row], cellImageType: arrImageOptions[indexPath.row])
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate Methods

extension MenuController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(63)
    }
}

// MARK: - AddEditPlanningCellDelegate Methods
extension MenuController: MenuCellDelegate {
    func didSelectOption(curCellType: MenuCellType) {
        
        switch curCellType {
        case .addAsDefault:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
            
        case .shareFreespoke:
            shareFresspoke()
            
        case .appSettings, .bookmars:
            dismissScreen()
            
            delegate?.didSelectOption(curCellType: curCellType)
            
        default:
            delegate?.didSelectOption(curCellType: curCellType)
            
            dismissScreen()
        }
    }
}



