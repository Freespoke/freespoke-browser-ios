// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

final class WhiteListTVC: UIViewController {
    
    lazy var whiteListViewModel: WhiteListViewModel = WhiteListViewModel(delegate: self)
    
    var currentTheme: Theme
    
    private let navigationView = CustomTitleView()
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    var closureTappedOnBtnSwitch: (() -> Void)?
        
    init(currentTheme: Theme) {
        self.currentTheme = currentTheme
        super.init(nibName: nil, bundle: nil)
        self.navigationView.setCurrentTheme(currentTheme: self.currentTheme)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
        self.prepareTableView()
        self.registerComponents()
        self.addingViews()
        self.setupConstraints()
        self.subscribeClosures()
        self.subscribeNotifications()
        self.hideKeyboardWhenTappedAround()
    }
    
    private func prepareUI() {
        self.view.backgroundColor = .white
        self.updateColorForUIItems()
    }
    
    private func prepareTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.bounces = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
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
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.navigationView)
    }
    
    private func setupConstraints() {
        self.navigationView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40),
            self.navigationView.heightAnchor.constraint(equalToConstant: 60),
            
            self.tableView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 0),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
        ])
    }
    
    private func subscribeClosures() {
        self.navigationView.backButtonTapClosure = { [weak self] in
            self?.motionDismissViewController(animated: true)
        }
    }
    
    private func updateColorForUIItems() {
        switch currentTheme.type {
        case .dark:
            self.view.backgroundColor = UIColor.black
        case .light:
            self.view.backgroundColor = .gray7
        }
        self.tableView.backgroundColor = .clear
    }
}
// MARK: Table view delegates and datasource
extension WhiteListTVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.whiteListViewModel.getNumberOfSection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.whiteListViewModel.getNumberOfRowsInSection(section: section)
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
    
    func showConfirmAlertForDeleteDomain(completion: @escaping (() -> Void)) {
        let alert = UIAlertController.deleteDomainAlert({ _ in completion() })
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
