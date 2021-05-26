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
    @IBOutlet weak var questionFrontLabel: UILabel!
    @IBOutlet weak var showHideButtonLabel: UIButton!
    
    @IBOutlet weak var audioBackLabel: UIButton!
    @IBOutlet weak var textBackField: UITextView!
    
    @IBOutlet weak var againButtonLabel: UIButton!
    @IBOutlet weak var completeButtonLabel: UIButton!
    @IBOutlet weak var backToLessonButtonLabel: UIButton!
    
    var cardLesson = [CardData]()
    var cardIndex = 0
    
    var avPlayer: AVPlayer?
    var avPlayerItem: AVPlayerItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
                            
    }
    
    func updateUI() {
        let label = cardLesson[cardIndex].cardName
            lessonLabel.text = label
        
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
        
    }
    @IBAction func againButtonPressed(_ sender: UIButton) {
    }
    @IBAction func completeButtonPressed(_ sender: UIButton) {
    }
    @IBAction func backToLessonButtonPressed(_ sender: UIButton) {
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
