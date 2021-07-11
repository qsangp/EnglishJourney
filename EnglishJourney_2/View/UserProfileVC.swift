//
//  UserProfileVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 29/05/2021.
//

import UIKit
import GoogleSignIn
import Kingfisher

class UserProfileVC: UIViewController {
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UINib(nibName: "ProfileTableViewCell",
                          bundle: nil),
                    forCellReuseIdentifier: "ProfileTableViewCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = UITableViewCell.SeparatorStyle.none
        return tv
    }()
    
    var againButtonDayCount = 0
    var completeButtonDayCount = 0
    
    private let supportButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Chat with us", for: .normal)
        button.setTitleColor(UIColor(red: 0.00, green: 0.64, blue: 0.64, alpha: 1.00), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.titleLabel?.textAlignment = .left
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(supportButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let logOutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign out", for: .normal)
        button.setTitleColor(UIColor(red: 0.00, green: 0.64, blue: 0.64, alpha: 1.00), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.titleLabel?.textAlignment = .left
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(logOutButtonPressed), for: .touchUpInside)
        return button
    }()
    
    var viewModel: CardViewModel!
    let parentId = UserDefaults.standard.integer(forKey: "currentParentId")
    
    deinit {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "PeformAfterUpdateChart"),
            object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabbarController = tabBarController as! CustomTabBarVC
        viewModel = tabbarController.viewModel
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(updateUI),
            name: NSNotification.Name(rawValue: "PeformAfterPresenting"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(updateUI),
            name: NSNotification.Name(rawValue: "userCompleteCard"),
            object: nil)
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        viewModel.requestChartDataTotal()
        viewModel.needPerformAction = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc func updateUI() {
        overrideUserInterfaceStyle = .light
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75).isActive = true
        
        viewModel.requestChartDataTotal()
        viewModel.needPerformAction = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc func supportButtonPressed() {
        guard let url = URL(string: "https://www.facebook.com/ieltsvuive/") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func logOutButtonPressed() {
        
        let signOutAlert = UIAlertController(title: "Sign out of English Journey?", message: "", preferredStyle: UIAlertController.Style.alert)
        
        signOutAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            resetDefaults()
            KeychainItem.deleteUserIdentifierFromKeychain()
            GIDSignIn.sharedInstance().signOut()
            self.showLoginVCFromHomeVC()
        }))
        
        signOutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("User canncels sign out")
        }))
        
        present(signOutAlert, animated: true, completion: nil)
        
    }
}

extension UserProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return view.frame.width
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell") as! ProfileTableViewCell
        cell.selectionStyle = .none
        
        switch indexPath.row {
        case 0:
            cell.setupImage()
            return cell
        case 1:
            cell.viewModel = viewModel
            let hits = viewModel.buttonDataHits()?.againDataHits
            if hits?.reduce(0,+) == 0 {
                cell.setupNoChartView()
            } else {
                cell.createChart()
            }
            return cell
        case 2:
            cell.addSubview(supportButton)
                supportButton.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 15).isActive = true
                supportButton.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -15).isActive = true
                supportButton.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5).isActive = true
                supportButton.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5).isActive = true
                supportButton.heightAnchor.constraint(equalToConstant: cell.frame.width/7).isActive = true
            return cell
        case 3:
            cell.addSubview(logOutButton)
            logOutButton.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 15).isActive = true
                logOutButton.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -15).isActive = true
                logOutButton.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5).isActive = true
                logOutButton.bottomAnchor.constraint(equalTo: cell.bottomAnchor,constant: -5).isActive = true
                logOutButton.heightAnchor.constraint(equalToConstant: cell.frame.width/7).isActive = true
            return cell
        default:
            return cell
        }
    }
    
}
