//
//  CardLessonVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 26/05/2021.
//

import UIKit
import AVFoundation

class CardLessonVC: UIViewController {
    
    @IBOutlet weak var lessonLabel: UILabel!
    @IBOutlet weak var audioFrontLabel: UIButton!
    @IBOutlet weak var textFrontLabel: UILabel!
    @IBOutlet weak var showHideButtonLabel: UIButton!
    
    @IBOutlet weak var audioBackLabel: UIButton!
    @IBOutlet weak var textBackField: UITextView!
    
    @IBOutlet weak var againButtonLabel: UIButton!
    @IBOutlet weak var completeButtonLabel: UIButton!
    @IBOutlet weak var backToLessonButtonLabel: UIButton!
    
    @IBOutlet weak var constraintFrontCardViewTop: NSLayoutConstraint!
    @IBOutlet weak var constraintFrontCardBackCard: NSLayoutConstraint!
    @IBOutlet weak var constraintFrontCardViewBottom: NSLayoutConstraint!
    
    
    var cardLesson = [CardData]()
    var cardIndex = 0
    
    var avPlayer: AVPlayer?
    var avPlayerItem: AVPlayerItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
                            
    }
    
    func updateUI() {
        textFrontLabel.isHidden = true
        audioBackLabel.isHidden = true
        textBackField.isHidden = true
        
        constraintFrontCardBackCard.priority = UILayoutPriority.defaultLow
        constraintFrontCardViewBottom.priority = UILayoutPriority.defaultHigh
        constraintFrontCardViewTop.constant = 200
        constraintFrontCardViewBottom.constant = 400
        
        showHideButtonLabel.setTitle("Show Sample", for: .normal)
        
        let cardName = cardLesson[cardIndex].cardName
            lessonLabel.text = cardName
        print("updateUI: \(cardIndex), \(cardLesson.count)")
        
        // Render HTML
        let htmlString = cardLesson[cardIndex].backCardText
        
        textBackField.attributedText = htmlString.htmlAttributedString()
        
    }
    
//MARK: - Audio Section
    
    @IBAction func audioFrontPressed(_ sender: UIButton) {
        let baseURL = "https://app.ielts-vuive.com/data/audio/"
        let id = String(cardLesson[cardIndex].id)
        let audioName = cardLesson[cardIndex].frontCardAudio
        
        let sourceAudio = "\(baseURL)\(id)/\(audioName)"
        let url = URL(string: sourceAudio)
        do {
              try AVAudioSession.sharedInstance().setCategory(.playback)
                avPlayerItem = AVPlayerItem.init(url: url! as URL)
                avPlayer = AVPlayer.init(playerItem: avPlayerItem)
                avPlayer?.volume = 1.0
                avPlayer?.play()
            
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func audioBackPressed(_ sender: UIButton) {
        let baseURL = "https://app.ielts-vuive.com/data/audio/"
        let id = String(cardLesson[cardIndex].id)
        let audioName = cardLesson[cardIndex].backCardAudio
        
        let sourceAudio = "\(baseURL)\(id)/\(audioName)"
        let url = URL(string: sourceAudio)
        do {
              try AVAudioSession.sharedInstance().setCategory(.playback)
                avPlayerItem = AVPlayerItem.init(url: url! as URL)
                avPlayer = AVPlayer.init(playerItem: avPlayerItem)
                avPlayer?.volume = 1.0
                avPlayer?.play()
            
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
//MARK: - Lesson Section
    
    @IBAction func showHideButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            showHideButtonLabel.setTitle("Hide Sample", for: .normal)

            audioBackLabel.isHidden = false
            textBackField.isHidden = false
            
            constraintFrontCardBackCard.priority = UILayoutPriority.defaultHigh
            constraintFrontCardViewBottom.priority =
                UILayoutPriority.defaultLow
            constraintFrontCardViewTop.constant = 50

        } else {
            showHideButtonLabel.setTitle("Show Sample", for: .normal)

            audioBackLabel.isHidden = true
            textBackField.isHidden = true
            
            constraintFrontCardBackCard.priority = UILayoutPriority.defaultLow
            constraintFrontCardViewBottom.priority = UILayoutPriority.defaultHigh
            constraintFrontCardViewTop.constant = 200
        }
    }
    @IBAction func againButtonPressed(_ sender: UIButton) {
        
        switch cardIndex {
            case cardLesson.count - 1:
                cardIndex = -1
                cardIndex += 1
                updateUI()
            default:
                cardIndex += 1
                updateUI()
        }
    }
    
    @IBAction func completeButtonPressed(_ sender: UIButton) {
        
        switch cardLesson.count - 1 {
            case 1:
                cardLesson.remove(at: cardIndex)
                cardIndex = 0
                updateUI()
            case 0:
                performSegue(withIdentifier: "GoToComplete", sender: self)
            default:
                cardLesson.remove(at: cardIndex)
                updateUI()
        }
        
    }
    
    @IBAction func backToLessonButtonPressed(_ sender: UIButton) {
        cardLesson = [CardData]()
        dismiss(animated: true, completion: nil)
    }


}

// MARK: - Render HTML
extension String {
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        return try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )
    }
}
