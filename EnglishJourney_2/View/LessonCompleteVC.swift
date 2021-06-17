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
    
    var cardCompleteData = [CardItems]()
    var clickedData: ChartData!
    
    deinit {
        print("CardComplete VC has no retain cycle")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    func updateUI() {
        overrideUserInterfaceStyle = .light

        learnAgainButton.layer.cornerRadius = 10
        backToLessonsButton.layer.cornerRadius = 10
        
        if let nameCard = cardCompleteData.first?.title {
            let newNameCard = nameCard.prefix(nameCard.count - 3)
            congratMessage.textColor = .label
            congratMessage.text = "Congrats! \nYou have completed the lesson: \(newNameCard) \nAgain: \(clickedData.againButtonPressedLog) \nComplete: \(clickedData.completeButtonPressedLog)"
        }
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(backToLessonsPressed(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(learnAgainPressed(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @IBAction func learnAgainPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backToLessonsPressed(_ sender: UIButton) {
        UserDefaults.standard.setValue(true, forKey: "isUserCompleted")
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
