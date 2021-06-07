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
    
    // Data
    var cardViewModel: CardViewModel!
    var flashCard: [CardModel]!
    var flashCardData = [[CardData]]()
    
    var cardParentId = 186
    var menuTitle = "Lesson"
    
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
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkCurrentParentId()
        updateUI()
        print("will appear get call")
    }
    
    func checkCurrentParentId() {
        let currentParentId = UserDefaults.standard.integer(forKey: "cardParentId")
        let currentMenuTitle = UserDefaults.standard.string(forKey: "cardMenuTitle")
        if currentParentId != 0 {
            cardParentId = currentParentId
            menuTitle = currentMenuTitle ?? "Speaking Task 1"
            print("currenId \(currentParentId)")
        }
    }
    
    func updateUI() {
        self.tableView.isUserInteractionEnabled = false
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.activityIndicator.startAnimating()
                
        cardViewModel = CardViewModel()
        cardViewModel.fetchFlashCardsByParentId(parentId: cardParentId) { error in
            if error != nil {
                Alert.showBasic(title: "Unable To Fetch Flashcard", message: "Something went wrong. Please try again later...", vc: self)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            } else {
                self.tableView.reloadData()
                self.tableView.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
            }
        }
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            cardViewModel.checkToken(token: accessToken) { (userData, tokenError) in
                self.hiUser.text = "Chào \(userData?.userNameOrEmail ?? "bạn")"
                UserDefaults.standard.setValue(userData?.id, forKey: "userId")
                let userImageURL = UserDefaults.standard.url(forKey: "userImageURL")
                if let url = userImageURL {
                    self.profileButton.getURL2(url: url)
                }
            }
        }
        
        activityIndicator.startAnimating()
        
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
    }
    
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "GoToProfile", sender: self)
    }
    
    func randomLessonPressed() {
        activityIndicator.startAnimating()
        
        let id = cardViewModel.flashcard[Int.random(in: 1..<cardViewModel.flashcard.count)].id
        self.cardViewModel.flashcardData = [CardData]()
        self.cardViewModel.fetchFlashCardsData(id: id) { error in
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
        return cardViewModel.flashcard.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RandomQuestionViewCell") as! RandomQuestionViewCell
            cell.selectionStyle = .none
            return cell
            
        } else {
            let card = cardViewModel.flashcard[indexPath.row - 1]
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell") as! MyTableViewCell
            cell.selectionStyle = .none
            cell.titleLabel.text = card.title
            cell.numberLabel.text = "Number of Lesson: \(card.numOfLesson)"
            
            return cell
        }
    }
    
    // Chiều cao Header của tableview
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    // Menu chọn lessons
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let menuButton: UIButton = {
            let button = UIButton()
            button.setTitleColor(UIColor.systemGray, for: .normal)
            button.setTitle("\(menuTitle) ↓", for: .normal)
            return button
        }()
        menuButton.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        
        return menuButton
    }
    
    @objc func didTapMenuButton() {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "GoToMenu") as! MenuVC

        let navigationController: UINavigationController = UINavigationController(rootViewController: viewController)

        navigationController.modalPresentationStyle = .fullScreen

        present(navigationController, animated: true, completion: nil)
        
    }
    
    // Push màn hình theo size custom
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
            return HalfSizePresentationController(presentedViewController: presented, presenting: presentingViewController)
        }
    
    // Chiều cao của row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        } else {
            return 120
        }
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
        
        if indexPath.row == 0 {
            randomLessonPressed()
            
        } else {
            activityIndicator.startAnimating()
            let selectedID = cardViewModel.flashcard[indexPath.row - 1].id
            self.cardViewModel.flashcardData = [CardData]()
            self.cardViewModel.fetchFlashCardsData(id: selectedID) { error in
                print(indexPath.row)
                print(selectedID)
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

class HalfSizePresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let bounds = containerView?.bounds else { return .zero }
        return CGRect(x: 0, y: bounds.height / 3, width: bounds.width, height: bounds.height)
    }
}


