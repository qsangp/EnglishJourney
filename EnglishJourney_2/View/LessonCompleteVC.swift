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
        
        learnAgainButton.layer.cornerRadius = 20
        backToLessonsButton.layer.cornerRadius = 20
        
        if let nameCard = cardCompleteData.first?.title {
            let newNameCard = nameCard.prefix(nameCard.count - 3)
            
            congratMessage.text = "Congrats! \nYou have completed the lesson: \(newNameCard) \nAgain: \(clickedData.againButtonPressedLog) \nComplete: \(clickedData.completeButtonPressedLog)"
        }
    }
    
    @IBAction func learnAgainPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backToLessonsPressed(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
