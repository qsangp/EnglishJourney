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
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButon: UIButton!
    @IBOutlet weak var textBackField: UITextView!
    @IBOutlet weak var textMessage: UILabel!
    
    @IBOutlet weak var againButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var backToLessonButton: UIButton!
    @IBOutlet weak var audioSlider: UISlider!
    
    @IBOutlet weak var constraintFrontCardViewTop: NSLayoutConstraint!
    @IBOutlet weak var constraintFrontCardBackCard: NSLayoutConstraint!
    @IBOutlet weak var constraintFrontCardViewBottom: NSLayoutConstraint!
    
    // Record
    @IBOutlet var recordingTimeLabel: UILabel!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playRecordButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    
    // Card Lesson
    var cardViewModel: CardViewModel!
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
        
        checkRecordPermission()
        updateUI(autoPlayAudio: true)
        
    }
    // Record Audio
    
    @IBAction func start_recording(_ sender: UIButton)
    {
        if(isRecording)
        {
            finishAudioRecording(success: true)
            recordButton.setTitle("Record", for: .normal)
            playRecordButton.isEnabled = true
            isRecording = false
        }
        else
        {
            setup_recorder()
            
            audioRecorder.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            recordButton.setTitle("Stop", for: .normal)
            playRecordButton.isEnabled = false
            isRecording = true
        }
    }
    
    @objc func updateAudioMeter(timer: Timer)
    {
        if audioRecorder.isRecording
        {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            recordingTimeLabel.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    @IBAction func play_recording(_ sender: Any)
    {
        if(isPlaying)
        {
            audioPlayer.stop()
            recordButton.isEnabled = true
            playRecordButton.setTitle("Play", for: .normal)
            isPlaying = false
        }
        else
        {
            if FileManager.default.fileExists(atPath: getFileUrl().path)
            {
                recordButton.isEnabled = false
                prepare_play()
                audioPlayer.play()
                isPlaying = true
            }
            else
            {
                print("audio is missing")
            }
        }
    }
    
    func updateUI(autoPlayAudio: Bool) {
        cardViewModel = CardViewModel()
        
        // UI
        overrideUserInterfaceStyle = .light
        
        textFrontLabel.isHidden = true
        audioBackButton.isHidden = true
        audioSlider.isHidden = true
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
        pauseButton.isHidden = true
        playButon.isHidden = true
        
        // Slider
        audioSlider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)

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
        avPlayer?.addObserver(self, forKeyPath: "currentTime", options: .new, context: nil)
        
        let sourceAudio = "\(baseURL)\(id)/\(audioName)"
        let url = URL(string: sourceAudio)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            avPlayerItem = AVPlayerItem.init(url: url! as URL)
            avPlayer = AVPlayer.init(playerItem: avPlayerItem)
            avPlayer?.volume = 1.0
            avPlayer?.play()
            audioBackButton.isHidden = true
            pauseButton.isHidden = false
            playButon.isHidden = true
            
        } catch(let error) {
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func playPressed(_ sender: Any) {
        avPlayer?.play()
        pauseButton.isHidden = false
        playButon.isHidden = true
    }
    
    @IBAction func pausePressed(_ sender: Any) {
        avPlayer?.pause()
        pauseButton.isHidden = true
        playButon.isHidden = false
    }
    
        
    @objc func handleSliderChange() {
        
        if let duration = avPlayer?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(audioSlider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            avPlayer?.seek(to: seekTime)
        }
    }
    
    @objc func updateSlider() {
        if let duration = avPlayer?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let currentTimeBySecond = CMTimeGetSeconds((avPlayer!.currentTime()))
            audioSlider.value = Float(currentTimeBySecond / totalSeconds)
        }
        if audioSlider.value == audioSlider.maximumValue {
            audioSlider.value = 0
            avPlayer?.pause()
            audioBackButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func audioSlider(_ sender: Any) {
    }
    
    
    //MARK: - Lesson Section
    
    @IBAction func showHideButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            showHideButton.setTitle("Hide Sample", for: .normal)
            
            audioSlider.isHidden = false
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
        deleteRecordedAudio()
        recordingTimeLabel.text = ""
        againButtonPressedLog += 1
        
        // Write log again button
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            cardViewModel.checkToken(token: accessToken) { (userData, tokenError) in
                if let userId = userData?.id {
                    let cardId = self.temporaryCardLesson[self.cardIndex].id
                    self.cardViewModel.writeLogButon(buttonName: "Again", cardId: cardId, categoryId: 186, userId: userId) {
                        print("Log Again Buton Success")
                    }
                } else {
                    print("no log")}
            }
        }
        
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
        deleteRecordedAudio()
        recordingTimeLabel.text = ""
        completeButtonPressedLog += 1
        
        // Write log complete button
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            cardViewModel.checkToken(token: accessToken) { (userData, tokenError) in
                if let userId = userData?.id {
                    let cardId = self.temporaryCardLesson[self.cardIndex].id
                    self.cardViewModel.writeLogButon(buttonName: "Easy", cardId: cardId, categoryId: 186, userId: userId) {
                        print("Log complete Buton Success")
                    }
                } else {
                    print("no log")}
            }
        }
        
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
        deleteRecordedAudio()
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

extension AVPlayer {

}

