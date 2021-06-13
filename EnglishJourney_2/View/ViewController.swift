//
//  ViewController.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import UIKit

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var hiUser: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileButton: UIImageView!
    
    // Mode
    var isMenuOn = true
    
    // Data
    var viewModel: CardViewModel!
    let service = Service()
    var cardParentId = 186
    var menuTitle = "☰ MENU"
    
    deinit {
        print("VC has no retain cycle")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        self.initTableView()
        self.bindViewModel()
        self.updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /// Bind view model
    private func bindViewModel() {
        viewModel = CardViewModel()
        
        viewModel.needReloadTableView = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.needShowError = { [weak self] error in
            self?.showError(error: error)
        }
        viewModel.requestCard()
    }
    
    /// Show error alert when call API error
    /// - Parameter error: error from server
    private func showError(error: ErrorMessage) {
        let alert = UIAlertController(title: "Error", message: error.rawValue, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func updateUI() {
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        if isMenuOn {
            menuTitle = "☰ MENU"
        } else if let title = UserDefaults.standard.string(forKey: "currentCardTitle") {
            let cardId = UserDefaults.standard.integer(forKey: "cardParentId")
            menuTitle = "\(title) ↑"
            cardParentId = cardId
        }
        
        if let userName = UserDefaults.standard.string(forKey: "userName") {
              self.hiUser.text = "Hi \(userName)"
              let userImageURL = UserDefaults.standard.url(forKey: "userImageURL")
              if let url = userImageURL {
                self.profileButton.downloaded(from: url)
          }
      }
    }
    
    func initTableView() {
        tableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "MyTableViewCell")
        tableView.register(UINib(nibName: "RandomQuestionViewCell", bundle: nil), forCellReuseIdentifier: "RandomQuestionViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
        
    func randomLessonPressed() {
        
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isMenuOn {
            return viewModel.numberOfRowsInSection(section: section)
        } else {
            return viewModel.numberOfRowsInSectionLessons(parentId: cardParentId, section: section)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isMenuOn {
            let card = viewModel.cellForRowAt(indexPath: indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell") as! MyTableViewCell
            cell.selectionStyle = .none
            cell.titleLabel.text = card.title
            cell.numberLabel.text = "Lessons: \(card.items.count)"
            
            return cell
            
        } else {
            let card = viewModel.cellForRowAtLessons(parentId: cardParentId, indexPath: indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell") as! MyTableViewCell
            let numberOfLesson = viewModel.numberOfLesson(cardId: card.id)
            let completion = viewModel.numberOfCompletion(cardId: card.id)
            cell.selectionStyle = .none
            cell.titleLabel.text = card.title
            cell.numberLabel.text = "Lessons: \(numberOfLesson) - Completion: \(completion)"
            
            return cell
        }
    }
    
    // Chiều cao Header của tableview
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    // Menu chọn lessons
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let menuButton: UIButton = {
            let button = UIButton()
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            button.backgroundColor = .white
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor(red: 0.81, green: 0.82, blue: 0.83, alpha: 1.00).cgColor
            button.setTitle("\(menuTitle)", for: .normal)
            return button
        }()
        menuButton.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        
        return menuButton
    }
    
    @objc fileprivate func didTapMenuButton() {
        isMenuOn = true
        updateUI()
        tableView.reloadData()
    }
    
    // Chiều cao của row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // Kiểm tra data đã tải xong chưa
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
            }
        }
    }
    
    // Bấm chọn lesson trong row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isMenuOn {
            let cardCateItems = viewModel.cellForRowAt(indexPath: indexPath)
            for item in cardCateItems.items {
                viewModel.getDashboard(cardId: item.id)
                viewModel.requestChartDataCell(cardId: item.id)
            }
            cardParentId = cardCateItems.id
            menuTitle = cardCateItems.title
            UserDefaults.standard.setValue(menuTitle, forKey: "currentCardTitle")
            UserDefaults.standard.setValue(cardParentId, forKey: "cardParentId")
            print("parentId \(cardParentId)")
            viewModel.needReloadTableView = { [weak self] in
                self?.isMenuOn = false
                self?.updateUI()
                self?.tableView.reloadData()
            }
            
        } else {
            let cardLessonItems = viewModel.cellForRowAtLessons(parentId: cardParentId, indexPath: indexPath)
            
            let userId = UserDefaults.standard.integer(forKey: "userId")
            let selectedID = cardLessonItems.id
            UserDefaults.standard.setValue(selectedID, forKey: "cardId")
            print("cardId \(selectedID)")
                        
            service.fetchFlashCardsData(cateId: selectedID, userId: userId) { [weak self] results in
                switch results {
                case .success(let results):
                    if let results = results {
                        let vc = self?.storyboard?.instantiateViewController(identifier: "CardLesson") as! CardLessonVC
                        vc.cardLesson = results
                        vc.temporaryCardLesson = results

                        self?.present(vc, animated: true)
                    }
                case .failure(let error):
                    self?.showError(error: error)
                }
            }
        }
    }
}




