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
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var timeSetNotification: UITextField!
    
    var cardCompleteData = [CardData]()
    var clickedData: ChartData!
    var viewModel: CardViewModel!
    var cardId: Int!
            
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        if let previousTimeInput = UserDefaults.standard.string(forKey: "setTimeNotification") {
            timeSetNotification.text = previousTimeInput
        } else {
            timeSetNotification.text = "1"
        }
        
        if UserDefaults.standard.bool(forKey: "notificationSwitch") {
            notificationSwitch.isOn = true
        } else {
            notificationSwitch.isOn = false
        }
        
        timeSetNotification.delegate = self
        updateUI()
    }
    
    func updateUI() {
        overrideUserInterfaceStyle = .light
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        cardId = viewModel.getCurrentCardId()
        learnAgainButton.layer.cornerRadius = 10
        
        backToLessonsButton.layer.cornerRadius = 10
        backToLessonsButton.layer.borderWidth = 0.5
        backToLessonsButton.layer.borderColor = UIColor(red: 0.00, green: 0.64, blue: 0.64, alpha: 1.00).cgColor
        
        if let nameCard = cardCompleteData.first?.title {
            let title = nameCard.replacingOccurrences(of: "01", with: "")
            congratMessage.textColor = .label
            congratMessage.text = "Congrats! \nYou have completed the lesson \n\(title.localizedCapitalized)"
        }
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(backToLessonsPressed(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(learnAgainPressed(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @IBAction func learnAgainPressed(_ sender: UIButton) {
        setupButton()
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func backToLessonsPressed(_ sender: UIButton) {
        setupButton()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func notificationSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.setValue(true, forKey: "notificationSwitch")
        } else {
            UserDefaults.standard.setValue(false, forKey: "notificationSwitch")
        }
    }
    
    func setupButton() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userCompleteCard"), object: nil)
        if UserDefaults.standard.bool(forKey: "removeCardReview") {
            viewModel.removeCardToReview(cardId: cardId)
        } else {
            saveCards()
            setupLocalNotification()
        }
    }
    
    func saveCards() {
        let interval = Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: interval)
        viewModel.saveCardToReview(cardId: cardId, time: date)
        print("log card to review", cardId!, date)
    }
    
    func setupLocalNotification() {
        let title = cardCompleteData.first?.title.replacingOccurrences(of: "01", with: "").localizedCapitalized
        UserDefaults.standard.setValue(timeSetNotification.text, forKey: "setTimeNotification")
        let time = Int(timeSetNotification.text!) ?? 1
        if notificationSwitch.isOn {
//            LocalNotificationManager.setNotifications(time, of: .hours, repeats: false, title: "Bạn ơi", body: "Mình ôn tập \(title ?? "")nhé")
        }
    }
}
