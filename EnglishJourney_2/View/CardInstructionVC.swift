//
//  CardInstructionVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 17/06/2021.
//

import UIKit

class CardInstructionVC: UIViewController {

    @IBOutlet weak var imageInstruction: UIImageView!
    @IBOutlet weak var labelInstruction: UILabel!
    
    @IBOutlet weak var againButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var backToLessonButton: UIButton!
        
    // Card Lesson
    var viewModel: CardViewModel!
    var instruction: [Instruction]!
    var cardIndex = 0
    
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
        instruction = viewModel.getInstruction()
    }
        
    func updateUI() {        
        
        imageInstruction.image = UIImage(named: instruction[cardIndex].image)
        labelInstruction.text = instruction[cardIndex].name
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(completeButtonPressed(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(againButtonPressed(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @IBAction func againButtonPressed(_ sender: UIButton) {

        switch cardIndex {
        case 0:
            updateUI()
            dismiss(animated: true, completion: nil)
        default:
            cardIndex -= 1
            updateUI()
        }
    }
    
    @IBAction func completeButtonPressed(_ sender: UIButton) {
                
        switch cardIndex {
        case instruction.count - 1:
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

