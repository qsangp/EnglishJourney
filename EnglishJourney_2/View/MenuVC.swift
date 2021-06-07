//
//  MenuVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 06/06/2021.
//

import UIKit
import NVActivityIndicatorView

class MenuVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var cardViewModel: CardViewModel!
    
    // Loading animation
    let activityIndicator: NVActivityIndicatorView = {
        let loading = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: UIColor(red: 1.00, green: 0.39, blue: 0.38, alpha: 1.00), padding: 0)
        loading.translatesAutoresizingMaskIntoConstraints = false
        return loading
    }()
    
    // Turn off menuVC
    let dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cross-mark"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDimiss), for: .touchUpInside)
        return button
    }()
    
    @objc func handleDimiss() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        updateData()
        updateUI()
        setUpAnimation()
    }
    
    func updateUI() {
        overrideUserInterfaceStyle = .light
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        view.addSubview(dismissButton)
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            dismissButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            dismissButton.widthAnchor.constraint(equalToConstant: 30),
            dismissButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // Tải card categories
    func updateData() {
        activityIndicator.startAnimating()
        
        cardViewModel = CardViewModel()
        cardViewModel.fetchFlashCards { error in
            if error != nil {
                Alert.showBasic(title: "Unable To Fetch Flashcard", message: "Something went wrong. Please try again later...", vc: self)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            } else {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func initTableView() {
        tableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "MyTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setUpAnimation() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 40),
            activityIndicator.heightAnchor.constraint(equalToConstant: 40),
        ])
        activityIndicator.stopAnimating()
    }
}

extension MenuVC: UITableViewDataSource, UITableViewDelegate {
    
    // Number of row in tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardViewModel.cardCategory.count
    }
    
    // Chiều cao row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    // Nạp data vào row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = cardViewModel.cardCategory[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell") as! MyTableViewCell
        cell.selectionStyle = .none
        cell.titleLabel.text = card.title
        cell.numberLabel.text = "Number of Lesson: \(card.numOfLesson)"
        
        return cell
    }
    
    // Kiểm tra data đã nạp xong chưa
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    // Nạp lại data cho lesson screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activityIndicator.startAnimating()
        
        // Lấy parent Id
        let selectedID = cardViewModel.cardCategory[indexPath.row].id
        
        self.cardViewModel.fetchFlashCardsByParentId(parentId: selectedID) { error in
            if error != nil {
                Alert.showBasic(title: "Unable To Fetch Flashcard", message: "Something went wrong. Please try again later...", vc: self)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                
            } else {
                let vc = self.storyboard?.instantiateViewController(identifier: "GoToVC") as! ViewController
                vc.cardParentId = selectedID
                let currentMenuTitle = self.cardViewModel.cardCategory[indexPath.row].title
                UserDefaults.standard.setValue(selectedID, forKey: "cardParentId")
                UserDefaults.standard.setValue(currentMenuTitle, forKey: "cardMenuTitle")
                vc.menuTitle = currentMenuTitle
                print("parent \(vc.cardParentId)")
                print("menu \(vc.menuTitle)")
                self.dismiss(animated: true)
                self.activityIndicator.stopAnimating()
            }
        }
    }
}

