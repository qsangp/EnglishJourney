//
//  ViewController.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import UIKit
import Kingfisher

class ViewController: UIViewController, UIViewControllerTransitioningDelegate, CategoryTableVCDelegate {
    
    func callSegueFromCell(cards: [CardItems]) {
        
        let vc = self.storyboard?.instantiateViewController(identifier: "CardLesson") as! CardLessonVC
        vc.cardLesson = cards
        vc.temporaryCardLesson = cards
        
        self.present(vc, animated: true)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    // Mode
    var isMenuOn = true
    
    // Data
    var viewModel: CardViewModel!
    let service = Service()
    var cardParentId = 186
    var menuTitle = ""
    
    deinit {
        print("VC has no retain cycle")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.initTableView()
        self.bindViewModel()
        self.updateUI()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkUserCompleteCard()
    }
    
    private func setupNavigationBar() {
        configureItems()
    }
    
    func configureItems() {
        navigationController?.overrideUserInterfaceStyle = .light
        let leftLabel = UILabel()
        if isMenuOn {
            leftLabel.text = "English Journey"
        } else {
            leftLabel.text = UserDefaults.standard.string(forKey: "currentCardTitle")?.localizedCapitalized
        }
        leftLabel.font = UIFont.boldSystemFont(ofSize: 18)
        leftLabel.sizeToFit()
        
        let leftItem = UIBarButtonItem(customView: leftLabel)
        self.navigationItem.leftBarButtonItem = leftItem
        
        let leftButton: UIButton = {
            let button = UIButton()
            button.setTitleColor(UIColor.label, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            button.setTitle("\(menuTitle)", for: .normal)
            return button
        }()
        leftButton.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        
        let rightItem = UIBarButtonItem(customView: leftButton)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    @objc fileprivate func didTapMenuButton() {
        isMenuOn = true
        updateUI()
        tableView.reloadData()
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
    
    func checkUserCompleteCard() {
        let isUserComplete = UserDefaults.standard.bool(forKey: "isUserCompleted")
        if isUserComplete {
            let cardId = UserDefaults.standard.integer(forKey: "cardId")
            viewModel.requestChartDataCell(cardId: cardId)
            UserDefaults.standard.setValue(false, forKey: "isUserCompleted")
        }
    }
    
    func updateUI() {
        
        if !isMenuOn {
            let cardId = UserDefaults.standard.integer(forKey: "cardParentId")
            menuTitle = "BACK"
            cardParentId = cardId
            configureItems()
        } else {
            menuTitle = ""
            configureItems()
        }
    }
    
    func initTableView() {
        tableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "MyTableViewCell")
        tableView.register(UINib(nibName: "CategoryTableVC", bundle: nil), forCellReuseIdentifier: "CategoryTableVC")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    @objc private func randomLessonPressed() {
        
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableVC") as! CategoryTableVC
            cell.bindData(data: card)
            cell.cardIdReview = viewModel.getCardIdLearned()
            cell.delegate = self
            cell.selectionStyle = .none
            
            return cell
            
        } else {
            let card = viewModel.cellForRowAtLessons(parentId: cardParentId, indexPath: indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell") as! MyTableViewCell
            
            cell.selectionStyle = .none
            
            var completionToday = 0
            var completionMonth = 0
            if card.numOfLession > 0 {
                completionToday = viewModel.numberOfCompletionToday(cardId: card.id) / card.numOfLession
                completionMonth = viewModel.numberOfCompletionMonth(cardId: card.id) / card.numOfLession
            }
            
            cell.bindData(data: card, completionToday: completionToday, completionMonth: completionMonth)
            
            if indexPath.row == 0 {
                cell.statusLabel.isHidden = false
                cell.statusLabel.text = "Instruction"
                cell.numberLabel.text = "Đọc kĩ trước khi dùng"
                cell.statusLabel.backgroundColor = UIColor(red: 0.40, green: 0.78, blue: 0.73, alpha: 1.00)
                cell.addStars(0)
            } else {
                cell.statusLabel.text = "Today: \(completionToday) | Total: \(completionMonth)"
                
            }
            
            return cell
        }
    }
    
    // Chiều cao của row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch isMenuOn {
        case true:
            return 210
        default:
            return 110
        }
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
            viewModel.requestChartData(cardId: cardCateItems.id)
            
            for item in cardCateItems.items {
                viewModel.requestChartDataCell(cardId: item.id)
            }
            
            cardParentId = cardCateItems.id
            menuTitle = cardCateItems.title
            UserDefaults.standard.setValue(menuTitle, forKey: "currentCardTitle")
            UserDefaults.standard.setValue(cardParentId, forKey: "cardParentId")
            print("parentId \(cardParentId)")
            isMenuOn = false
            updateUI()
            
        } else {
            let cardLessonItems = viewModel.cellForRowAtLessons(parentId: cardParentId, indexPath: indexPath)
            
            let selectedID = cardLessonItems.id
            UserDefaults.standard.setValue(selectedID, forKey: "cardId")
            print("cardId \(selectedID)")
            
            service.fetchFlashCardsData(cateId: selectedID) { [weak self] results in
                switch results {
                case .success(let results):
                    if let results = results {
                        if indexPath.row == 0 {
                            let vc = self?.storyboard?.instantiateViewController(identifier: "CardInstruction") as! CardInstructionVC
                            vc.cardLesson = results
                            vc.temporaryCardLesson = results
                            
                            self?.present(vc, animated: true)
                        } else {
                            let vc = self?.storyboard?.instantiateViewController(identifier: "CardLesson") as! CardLessonVC
                            vc.cardLesson = results
                            vc.temporaryCardLesson = results
                            
                            self?.present(vc, animated: true)
                        }
                    }
                case .failure(let error):
                    self?.showError(error: error)
                }
            }
        }
    }
}




