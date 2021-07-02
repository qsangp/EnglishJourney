//
//  LessonCompleteVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 27/05/2021.
//

import UIKit

class LessonCompleteVC: UIViewController {
    
    @IBOutlet weak var congratImage: UIImageView!
    @IBOutlet weak var congratMessage: UILabel!
    @IBOutlet weak var learnAgainButton: UIButton!
    @IBOutlet weak var backToLessonsButton: UIButton!
    
    var cardCompleteData = [CardData]()
    var clickedData: ChartData!
    var viewModel: CardViewModel!
    var cardId: Int!
    
    deinit {
        print("CardComplete VC has no retain cycle")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        updateUI()
    }
    
    func updateUI() {
        overrideUserInterfaceStyle = .light
        navigationController?.setNavigationBarHidden(true, animated: false)

        cardId = viewModel.getCurrentCardId()
        learnAgainButton.layer.cornerRadius = 10
        backToLessonsButton.layer.cornerRadius = 10
        
        if let nameCard = cardCompleteData.first?.title {
            congratMessage.textColor = .label
            congratMessage.text = "Congrats! \nYou have completed the lesson: \(nameCard) \nAgain: \(clickedData.againButtonPressedLog) \nComplete: \(clickedData.completeButtonPressedLog)"
        }
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(backToLessonsPressed(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(learnAgainPressed(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @IBAction func learnAgainPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userCompleteCard"), object: nil)
        if UserDefaults.standard.bool(forKey: "removeCardReview") {
            viewModel.removeCardToReview(cardId: cardId)
        } else {
            saveCards()
            setupLocalNotification()
        }
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func backToLessonsPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userCompleteCard"), object: nil)
        if UserDefaults.standard.bool(forKey: "removeCardReview") {
            viewModel.removeCardToReview(cardId: cardId)
        } else {
            saveCards()
            setupLocalNotification()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func saveCards() {
        let interval = Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: interval)
        viewModel.saveCardToReview(cardId: cardId, time: date)
        print("log card to review", cardId!, date)
    }
    
    func setupLocalNotification() {
        let title = cardCompleteData.first?.title.localizedCapitalized
        LocalNotificationManager.setNotifications(1, of: .minutes, repeats: false, title: "Bạn ơi", body: "Mình ôn tập \(title ?? "") nhé")
    }
    
}
