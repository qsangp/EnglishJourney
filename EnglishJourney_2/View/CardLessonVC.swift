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
    @IBOutlet weak var audioFrontButton: UIButton!
    @IBOutlet weak var textFrontLabel: UILabel!
    @IBOutlet weak var showHideButton: UIButton!
    
    @IBOutlet weak var audioBackButton: UIButton!
    @IBOutlet weak var textBackField: UITextView!
    @IBOutlet weak var textMessage: UILabel!
    
    @IBOutlet weak var againButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var backToLessonButton: UIButton!
    
    @IBOutlet weak var constraintFrontCardViewTop: NSLayoutConstraint!
    @IBOutlet weak var constraintFrontCardBackCard: NSLayoutConstraint!
    @IBOutlet weak var constraintFrontCardViewBottom: NSLayoutConstraint!
    
    // Card Lesson
    var cardLesson = [CardData]()
    var temporaryCardLesson = [CardData]()
    var cardIndex = 0
    
    // Audio
    var avPlayer: AVPlayer?
    var avPlayerItem: AVPlayerItem?
    
    // Chart Data
    var againButtonPressedLog = 0
    var completeButtonPressedLog = 0
    var chartData: ChartData!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI(autoPlayAudio: true)
                            
    }
    
    func updateUI(autoPlayAudio: Bool) {
        
        // UI
        overrideUserInterfaceStyle = .light

        textFrontLabel.isHidden = true
        audioBackButton.isHidden = true
        textBackField.isHidden = true
        textMessage.isHidden = false
        textBackField.isScrollEnabled = true
        
        showHideButton.layer.cornerRadius = 15
        againButton.layer.cornerRadius = 15
        completeButton.layer.cornerRadius = 15
         
        // Animation
        constraintFrontCardBackCard.priority = UILayoutPriority.defaultLow
        constraintFrontCardViewBottom.priority = UILayoutPriority.defaultHigh
        constraintFrontCardViewTop.constant = 200
        constraintFrontCardViewBottom.constant = 400
        
        showHideButton.setTitle("Show Sample", for: .normal)
        showHideButton.setTitleColor(.darkGray, for: .normal)
        
        let cardName = cardLesson[cardIndex].cardName
            lessonLabel.text = cardName
        print("updateUI: \(cardIndex), \(cardLesson.count)")
        
        // Render HTML
        let htmlString = cardLesson[cardIndex].backCardText
        
        textBackField.attributedText = htmlString.htmlAttributedString()
        
        // Autoplay Front Audio
        if autoPlayAudio {
            audioFrontButton.sendActions(for: .touchUpInside)
        }
        
    }
    
    func resetCardLesson() {
        cardLesson = temporaryCardLesson
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
            showHideButton.setTitle("Hide Sample", for: .normal)

            audioBackButton.isHidden = false
            textBackField.isHidden = false
            textMessage.isHidden = true
            
            constraintFrontCardBackCard.priority = UILayoutPriority.defaultHigh
            constraintFrontCardViewBottom.priority =
                UILayoutPriority.defaultLow
            constraintFrontCardViewTop.constant = 50

        } else {
            showHideButton.setTitle("Show Sample", for: .normal)

            audioBackButton.isHidden = true
            textBackField.isHidden = true
            textMessage.isHidden = false
            
            constraintFrontCardBackCard.priority = UILayoutPriority.defaultLow
            constraintFrontCardViewBottom.priority = UILayoutPriority.defaultHigh
            constraintFrontCardViewTop.constant = 200
        }
    }
    @IBAction func againButtonPressed(_ sender: UIButton) {
        avPlayer?.replaceCurrentItem(with: nil)
        againButtonPressedLog += 1
        
        switch cardIndex {
            case cardLesson.count - 1:
                cardIndex = -1
                cardIndex += 1
                updateUI(autoPlayAudio: true)
            default:
                cardIndex += 1
                updateUI(autoPlayAudio: true)
        }
    }
    
    @IBAction func completeButtonPressed(_ sender: UIButton) {
        avPlayer?.replaceCurrentItem(with: nil)
        completeButtonPressedLog += 1
        
        if cardIndex == 0 && cardLesson.count == 1 {
            chartData = ChartData(againButtonPressedLog: againButtonPressedLog, completeButtonPressedLog: completeButtonPressedLog)
            // Reset Card and Show Complete screen
            resetCardLesson()
            updateUI(autoPlayAudio: false)
            let vc = self.storyboard?.instantiateViewController(identifier: "LessonComplete") as! LessonCompleteVC
            vc.cardCompleteData = self.cardLesson
            vc.clickedData = self.chartData
            self.present(vc, animated: true)
            
        } else if cardIndex == cardLesson.count - 1 {
            cardLesson.remove(at: cardIndex)
            cardIndex = 0
            updateUI(autoPlayAudio: true)
        } else {
            cardLesson.remove(at: cardIndex)
            updateUI(autoPlayAudio: true)
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
        let htmlTemplate = """
            <!doctype html>
            <html>
              <head>
                <style>
                  body {
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    font-size: 3.5vw;
                    line-height: 1.4;
                  }
                </style>
              </head>
              <body>
                \(self)
              </body>
            </html>
            """

            guard let data = htmlTemplate.data(using: .utf8) else {
                return nil
            }

            guard let attributedString = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil
                ) else {
                return nil
            }

            return attributedString
    }
}
