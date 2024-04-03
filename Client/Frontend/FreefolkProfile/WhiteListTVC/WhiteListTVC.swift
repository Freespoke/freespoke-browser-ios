// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared
import Common

final class WhiteListTVC: UIViewController, Themeable {
    lazy var viewModel: WhiteListViewModel = WhiteListViewModel(delegate: self)
    
    private var contentView: UIView = {
        let cv = UIView()
        return cv
    }()
    
    private let navigationView = CustomTitleView()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    var themeManager: ThemeManager
    var notificationCenter: NotificationProtocol
    var themeObserver: NSObjectProtocol?
    
    var closureTappedOnBtnSwitch: (() -> Void)?
        
    init(themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default) {
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareTableView()
        self.registerComponents()
        self.addingViews()
        self.setupConstraints()
        self.subscribeClosures()
        self.subscribeNotifications()
        self.hideKeyboardWhenTappedAround()
        
        self.listenForThemeChange(self.view)
        self.applyTheme()
    }
    
    func applyTheme() {
        self.navigationView.applyTheme(currentTheme: self.themeManager.currentTheme)
        self.view.backgroundColor = (self.themeManager.currentTheme.type == .dark) ? UIColor.black : .gray7
        self.tableView.backgroundColor = .clear
        self.tableView.reloadData()
    }
    
    private func prepareTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.bounces = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset.bottom = self.view.safeAreaInsets.bottom
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
    }
    
    private func registerComponents() {
        // MARK: Register headers
        self.tableView.register(WhiteListHeaderView.self, forHeaderFooterViewReuseIdentifier: WhiteListHeaderView.reuseIdentifier)
        // MARK: Register cells
        self.tableView.register(WhiteListDomainCell.self, forCellReuseIdentifier: WhiteListDomainCell.reuseIdentifier)
        self.tableView.register(WhiteListBtnCell.self, forCellReuseIdentifier: WhiteListBtnCell.reuseIdentifier)
        self.tableView.register(AdBlockerCell.self, forCellReuseIdentifier: AdBlockerCell.reuseIdentifier)
        self.tableView.register(DomainTxtCell.self, forCellReuseIdentifier: DomainTxtCell.reuseIdentifier)
    }
    
    private func addingViews() {
        self.contentView.addSubview(self.tableView)
        self.view.addSubview(self.contentView)
        self.view.addSubview(self.navigationView)
    }
    
    private func setupConstraints() {
        self.navigationView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: constraints are set depending on the type of device iPad or iPhone
        if UIDevice.current.isPad {
            NSLayoutConstraint.activate([
                self.navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
                self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
                self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40),
                
                self.contentView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 20),
                self.contentView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 40),
                self.contentView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -40),
                self.contentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.contentView.widthAnchor.constraint(equalToConstant: Constants.DrawingSizes.iPadContentWidthStaticValue),
                self.contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
                
                self.tableView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
                self.tableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
                self.tableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
                self.tableView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
                self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
                self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40),
                
                self.contentView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 20),
                self.contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
                self.contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40),
                self.contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
                
                self.tableView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
                self.tableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
                self.tableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
                self.tableView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
            ])
        }
    }
    
    private func subscribeClosures() {
        self.navigationView.backButtonTappedClosure = { [weak self] in
            self?.motionDismissViewController(animated: true)
        }
    }
}

// MARK: Table view delegates and datasource
extension WhiteListTVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.getNumberOfSection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.prepareHeaders(tableView, viewForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.prepareCells(tableView, cellForRowAt: indexPath)
    }
}
// MARK: View model delegate
extension WhiteListTVC: WhiteListDelegate {
    func showErrorAlert(message: String) {
        let alert = UIAlertController.wrongEnteredDomainAlert(message: message)
        self.present(alert, animated: true)
    }
    
    func showConfirmAlertForDeleteDomain(domain: String, completion: @escaping (() -> Void)) {
        let title = "Delete Website"
        let message = "Removing <\(domain)> from the whitelist means you will see no longer see ads on this site unless you add it to your whitelist again."
        let alert = UIAlertController.deleteDomainAlert(title: title,
                                                        message: message,
                                                        deleteCallback: { _ in completion() })
        self.present(alert, animated: true)
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
}

extension WhiteListTVC {
    private func subscribeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
