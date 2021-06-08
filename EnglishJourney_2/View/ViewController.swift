//
//  ViewController.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import UIKit
import NVActivityIndicatorView

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var hiUser: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileButton: UIButton!
    
    // Mode
    var isFlashCardOn = false
    
    // Data
    var cardViewModel: CardViewModel!
    
    var cardParentId = 186
    var menuTitle = "☰ MENU"
    
    // Animation
    let activityIndicator: NVActivityIndicatorView = {
        let loading = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: UIColor(red: 1.00, green: 0.39, blue: 0.38, alpha: 1.00), padding: 0)
        loading.translatesAutoresizingMaskIntoConstraints = false
        return loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        setUpAnimation()
        initTableView()
        checkCurrentParentId()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    func checkCurrentParentId() {
        let currentParentId = UserDefaults.standard.integer(forKey: "cardParentId")
        if currentParentId != 0 {
            isFlashCardOn = true
            fetchData()
            tableView.reloadData()
        }
    }
    
    func fetchData() {
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.activityIndicator.startAnimating()
        if !isFlashCardOn {
            menuTitle = "☰ MENU"
        } else if let title = UserDefaults.standard.string(forKey: "currentCardTitle") {
            let cardId = UserDefaults.standard.integer(forKey: "cardParentId")
            menuTitle = "\(title) ↑"
            cardParentId = cardId
        }
        cardViewModel = CardViewModel()
        
        if !isFlashCardOn {
            cardViewModel.fetchFlashCards { error in
                if error != nil {
                    Alert.showBasic(title: "Unable To Fetch Flashcard", message: "Something went wrong. Please try again later...", vc: self)
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                } else {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        } else {
            cardViewModel.fetchFlashCardsByParentId(parentId: cardParentId) { error in
                if error != nil {
                    Alert.showBasic(title: "Unable To Fetch Flashcard", message: "Something went wrong. Please try again later...", vc: self)
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                } else {
                    self.tableView.reloadData()
                    self.tableView.isUserInteractionEnabled = true
                }
            }
        }
        
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            cardViewModel.checkToken(token: accessToken) { (userData, tokenError) in
                self.hiUser.text = "Hi \(userData?.userNameOrEmail ?? " ")"
                UserDefaults.standard.setValue(userData?.id, forKey: "userId")
                let userImageURL = UserDefaults.standard.url(forKey: "userImageURL")
                if let url = userImageURL {
                    self.profileButton.getURL2(url: url)
                }
            }
        }
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
    
    func initTableView() {
        tableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "MyTableViewCell")
        tableView.register(UINib(nibName: "RandomQuestionViewCell", bundle: nil), forCellReuseIdentifier: "RandomQuestionViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
    }
    
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "GoToProfile", sender: self)
    }
    
    func randomLessonPressed() {
        activityIndicator.startAnimating()
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let cateId = cardViewModel.flashcard[Int.random(in: 1..<cardViewModel.flashcard.count)].id
        self.cardViewModel.flashcardData = [CardData]()
        self.cardViewModel.fetchFlashCardsData(cateId: cateId, userId: userId) { error in
            if error != nil {
                Alert.showBasic(title: "Unable To Fetch Flashcard", message: "Something went wrong. Please try again later...", vc: self)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                
            } else {
                let vc = self.storyboard?.instantiateViewController(identifier: "CardLesson") as! CardLessonVC
                vc.cardLesson = self.cardViewModel.flashcardData.shuffled()
                vc.temporaryCardLesson = self.cardViewModel.flashcardData
                self.present(vc, animated: true)
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isFlashCardOn {
            return cardViewModel.cardCategory.count
        } else {
            return cardViewModel.flashcard.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isFlashCardOn {
            cardViewModel.cardCategory = cardViewModel.cardCategory.sorted {$0.title < $1.title}
            let card = cardViewModel.cardCategory[indexPath.row]
            print("cardcardcard \(indexPath.row)")
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell") as! MyTableViewCell
            cell.selectionStyle = .none
            cell.titleLabel.text = card.title
            cell.numberLabel.text = "Lesson: \(card.numOfLesson)"
            
            cell.backgroundView?.backgroundColor = UIColor.white
            
            return cell
            
        } else {
            cardViewModel.flashcard = cardViewModel.flashcard.sorted {$0.title < $1.title}
            let card = cardViewModel.flashcard[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell") as! MyTableViewCell
            cell.selectionStyle = .none
            cell.titleLabel.text = card.title
            cell.numberLabel.text = "Lesson: \(card.numOfLesson) - Completion: \(card.numOfCompletion)"
            if card.numOfCompletion > 0 {
                cell.cell_image.image = UIImage(named: "congrats")
            } else {
                cell.cell_image.image = UIImage(named: "open-book")
            }
            
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
        isFlashCardOn = false
        fetchData()
    }
    
    // Chiều cao của row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // Kiểm tra data đã tải xong chưa
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    // Bấm chọn lesson trong row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activityIndicator.startAnimating()
        
        if !isFlashCardOn {
            cardParentId = cardViewModel.cardCategory[indexPath.row].id
            menuTitle = cardViewModel.cardCategory[indexPath.row].title
            UserDefaults.standard.setValue(menuTitle, forKey: "currentCardTitle")
            UserDefaults.standard.setValue(cardParentId, forKey: "cardParentId")
            print("parentId \(cardParentId)")
            isFlashCardOn = true
            fetchData()
            tableView.reloadData()
            
        } else {
            let userId = UserDefaults.standard.integer(forKey: "userId")
            let selectedID = cardViewModel.flashcard[indexPath.row].id
            UserDefaults.standard.setValue(selectedID, forKey: "cardId")
            print("cardId \(selectedID)")
            self.cardViewModel.flashcardData = [CardData]()
            self.cardViewModel.fetchFlashCardsData(cateId: selectedID, userId: userId) { error in
                if error != nil {
                    Alert.showBasic(title: "Unable To Fetch Flashcard", message: "Something went wrong. Please try again later...", vc: self)
                    self.activityIndicator.stopAnimating()
                    
                } else {
                    let vc = self.storyboard?.instantiateViewController(identifier: "CardLesson") as! CardLessonVC
                    vc.cardLesson = self.cardViewModel.flashcardData
                    vc.temporaryCardLesson = self.cardViewModel.flashcardData
                    self.activityIndicator.stopAnimating()
                    self.present(vc, animated: true)
                }
            }
        }
    }
}



