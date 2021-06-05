//
//  ViewController.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import UIKit
import NVActivityIndicatorView

class ViewController: UIViewController {
    
    @IBOutlet weak var hiUser: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var greetView: UIView!
    @IBOutlet weak var greetMessage: UILabel!
    @IBOutlet weak var greetButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var constraintTableViewToTopView: NSLayoutConstraint!
    @IBOutlet weak var constraintTableViewToGreetView: NSLayoutConstraint!
    @IBOutlet weak var randomButton: UIButton!
    
    // Data
    var cardViewModel: CardViewModel!
    var flashCard: [CardModel]!
    var flashCardData = [[CardData]]()
    
    // Animation
    let activityIndicator: NVActivityIndicatorView = {
        let loading = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: UIColor(red: 0.58, green: 0.84, blue: 0.83, alpha: 1.00), padding: 0)
        loading.translatesAutoresizingMaskIntoConstraints = false
        return loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        setUpAnimation()
        initTableView()
        updataUI()
    }
    
    func updataUI() {
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        greetView.layer.cornerRadius = 20
        greetMessage.text = "What do we learn today?"
        greetButton.layer.cornerRadius = 10
        randomButton.isEnabled = false
        
        cardViewModel = CardViewModel()
        cardViewModel.fetchFlashCards { error in
            if error != nil {
                Alert.showBasic(title: "Unable To Fetch Flashcard", message: "Something went wrong. Please try again later...", vc: self)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            } else {
                self.flashCard = self.cardViewModel.flashcard
                self.tableView.reloadData()
                self.randomButton.isEnabled = true
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
    
    override func viewWillAppear(_ animated: Bool){
        tableView.reloadData()
    }
    
    /// Init table view
    private func initTableView() {
        tableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "MyTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "GoToProfile", sender: self)
    }
    
    @IBAction func hideGreetView(_ sender: UIButton) {
        greetView.isHidden = true
        constraintTableViewToTopView.priority = UILayoutPriority.defaultHigh
        constraintTableViewToGreetView.priority = UILayoutPriority.defaultLow
    }
    
    @IBAction func randomLessonPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        
        let id = flashCard[Int.random(in: 0..<flashCard.count)].id
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
        return cardViewModel.flashcard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let card = cardViewModel.flashcard[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell") as! MyTableViewCell
        
        cell.titleLabel.text = card.title
        cell.numberLabel.text = "Number of Lesson: \(card.numOfLesson)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activityIndicator.startAnimating()
        let selectedID = cardViewModel.flashcard[indexPath.row].id
        self.cardViewModel.flashcardData = [CardData]()
        self.cardViewModel.fetchFlashCardsData(id: selectedID) { error in
            print(indexPath.row)
            print(selectedID)
            if error != nil {
                Alert.showBasic(title: "Unable To Fetch Flashcard", message: "Something went wrong. Please try again later...", vc: self)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                
            } else {
                let vc = self.storyboard?.instantiateViewController(identifier: "CardLesson") as! CardLessonVC
                vc.cardLesson = self.cardViewModel.flashcardData
                vc.temporaryCardLesson = self.cardViewModel.flashcardData
                self.present(vc, animated: true)
                self.activityIndicator.stopAnimating()
            }
            
        }
        
    }
    
}


