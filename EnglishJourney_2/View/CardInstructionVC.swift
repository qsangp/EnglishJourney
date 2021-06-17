//
//  CardInstructionVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 17/06/2021.
//

import UIKit

class CardInstructionVC: UIViewController {

    @IBOutlet weak var lessonLabel: UILabel!
    
    @IBOutlet weak var textBackField: UITextView!
    @IBOutlet weak var backCardView: UIView!
    
    @IBOutlet weak var againButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var backToLessonButton: UIButton!
    
    // API
    let service = Service()
    
    // Card Lesson
    var viewModel: CardViewModel!
    var cardLesson = [CardItems]()
    var temporaryCardLesson = [CardItems]()
    var cardIndex = 1
    
    deinit {
        print("CardLesson VC has no retain cycle")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        bindViewModel()
        updateUI()
    }
    
    private func bindViewModel() {
        viewModel = CardViewModel()
    }
    
    func resetCardLesson() {
        cardLesson = temporaryCardLesson
    }
    
    func updateUI() {        
        // Render HTML
        let htmlString = cardLesson[cardIndex].backText
        
        textBackField.attributedText = htmlString.htmlAttributedString(fontSize: 16, color: "black")
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(completeButtonPressed(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(againButtonPressed(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @IBAction func againButtonPressed(_ sender: UIButton) {

        switch cardIndex {
        case 1:
            updateUI()
            dismiss(animated: true, completion: nil)
        default:
            cardIndex -= 1
            updateUI()
        }
    }
    
    @IBAction func completeButtonPressed(_ sender: UIButton) {
                
        switch cardIndex {
        case cardLesson.count - 1:
            updateUI()
            dismiss(animated: true, completion: nil)
        default:
            cardIndex += 1
            updateUI()
        }
    }
    
    @IBAction func backToLessonButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

