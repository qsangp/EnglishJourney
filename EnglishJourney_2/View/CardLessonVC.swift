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
    @IBOutlet weak var showHideButton: UIButton!
    
    @IBOutlet weak var audioBackButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButon: UIButton!
    @IBOutlet weak var textBackField: UITextView!
    @IBOutlet weak var backCardView: UIView!
    
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
    
    // API
    let service = Service()
    
    // Card Lesson
    var viewModel: CardViewModel!
    var cardLesson = [CardItems]()
    var temporaryCardLesson = [CardItems]()
    var cardIndex = 0
    
    let popUpMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Double tap to Show sample \nSwipe left → to click Done \nSwipe right ← to click Again"
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.masksToBounds = true
        return label
    }()
    
    let popUpImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "tap"))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    // Audio
    var avPlayer: AVPlayer?
    var avPlayerItem: AVPlayerItem?
    
    // Chart Data
    var againButtonPressedLog = 0
    var completeButtonPressedLog = 0
    var chartData: ChartData!
    
    deinit {
        print("CardLesson VC has no retain cycle")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        checkRecordPermission()
        updateUI(autoPlayAudio: true)
        
    }
    // Record Audio
    
    @IBAction func start_recording(_ sender: UIButton) {
        if (isRecording) {
            finishAudioRecording(success: true)
            recordButton.setTitle("Record", for: .normal)
            recordButton.setTitleColor(UIColor.label, for: .normal)
            playRecordButton.isEnabled = true
            isRecording = false
        }
        else {
            setup_recorder()
            
            audioRecorder.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            recordButton.setTitle("Stop", for: .normal)
            recordButton.setTitleColor(UIColor.systemRed, for: .normal)
            playRecordButton.isEnabled = false
            isRecording = true
        }
    }
    
    @objc func updateAudioMeter(timer: Timer) {
        if audioRecorder.isRecording {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            recordingTimeLabel.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    @IBAction func play_recording(_ sender: Any) {
        if(isPlaying) {
            audioPlayer.stop()
            recordButton.isEnabled = true
            playRecordButton.setTitle("Play", for: .normal)
            playRecordButton.setTitleColor(UIColor.label, for: .normal)
            isPlaying = false
        }
        else {
            if FileManager.default.fileExists(atPath: getFileUrl().path) {
                recordButton.isEnabled = false
                prepare_play()
                playRecordButton.setTitle("stop", for: .normal)
                playRecordButton.setTitleColor(UIColor.systemRed, for: .normal)
                audioPlayer.play()
                isPlaying = true
            }
            else {
                print("audio is missing")
            }
        }
    }
    
    private func bindViewModel() {
        viewModel = CardViewModel()
    }
    
    func updateUI(autoPlayAudio: Bool) {
        overrideUserInterfaceStyle = .light

        backCardView.isHidden = true
        textBackField.isScrollEnabled = true
        
        showHideButton.layer.cornerRadius = 10
        againButton.layer.cornerRadius = 10
        completeButton.layer.cornerRadius = 10
        
        // Animation
        constraintFrontCardBackCard.priority = UILayoutPriority.defaultLow
        constraintFrontCardViewBottom.priority = UILayoutPriority.defaultHigh
        constraintFrontCardViewTop.constant = 150
        constraintFrontCardViewBottom.constant = 400
        
        showHideButton.setTitle("Show Sample", for: .normal)
        showHideButton.setTitleColor(.label, for: .normal)
        
        let cardName = cardLesson[cardIndex].title
        lessonLabel.text = cardName
        
        // Render HTML
        let htmlString = cardLesson[cardIndex].backText
        
        textBackField.attributedText = htmlString.htmlAttributedString(fontSize: 16, color: "black")

        
        // Autoplay Front Audio
        if autoPlayAudio {
            audioFrontButton.sendActions(for: .touchUpInside)
        }
        pauseButton.isHidden = true
        playButon.isHidden = true
        
        // Slider
        audioSlider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        
        view.addSubview(popUpMessageLabel)
        popUpMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popUpMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popUpMessageLabel.topAnchor.constraint(equalTo: showHideButton.bottomAnchor, constant: 60),
            popUpMessageLabel.widthAnchor.constraint(equalToConstant: 300)
        ])
        
        view.addSubview(popUpImage)
        NSLayoutConstraint.activate([
            popUpImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popUpImage.topAnchor.constraint(equalTo: popUpMessageLabel.bottomAnchor, constant: 60),
            popUpImage.widthAnchor.constraint(equalToConstant: 100),
            popUpImage.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CardLessonVC.tapFunction))
        popUpMessageLabel.isUserInteractionEnabled = true
        popUpMessageLabel.addGestureRecognizer(tap)
        popUpImage.isUserInteractionEnabled = true
        popUpImage.addGestureRecognizer(tap)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(completeButtonPressed(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(againButtonPressed(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        showHideButton.sendActions(for: .touchUpInside)
    }
    
    func resetCardLesson() {
        cardLesson = temporaryCardLesson
    }
    
    //MARK: - Audio Section
    
    @IBAction func audioFrontPressed(_ sender: UIButton) {
        let baseURL = "https://app.ielts-vuive.com/data/audio/"
        let id = String(cardLesson[cardIndex].id)
        let audioName = cardLesson[cardIndex].audioFrontName
        
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
        let audioName = cardLesson[cardIndex].audioBackName
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
            audioBackButton.isHidden = false
            pauseButton.isHidden = true
        }
    }
    
    @IBAction func audioSlider(_ sender: Any) {
    }
    
    
    //MARK: - Lesson Section
    
    @IBAction func showHideButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            showHideButton.setTitle("Hide Sample", for: .normal)
            
            backCardView.isHidden = false
            audioFrontButton.isHidden = true
            popUpMessageLabel.isHidden = true
            popUpImage.isHidden = true
            
            constraintFrontCardBackCard.priority = UILayoutPriority.defaultHigh
            constraintFrontCardViewBottom.priority =
                UILayoutPriority.defaultLow
            constraintFrontCardViewTop.constant = 80
            
        } else {
            showHideButton.setTitle("Show Sample", for: .normal)
            
            backCardView.isHidden = true
            audioFrontButton.isHidden = false
            popUpMessageLabel.isHidden = false
            popUpImage.isHidden = false
            
            constraintFrontCardBackCard.priority = UILayoutPriority.defaultLow
            constraintFrontCardViewBottom.priority = UILayoutPriority.defaultHigh
            constraintFrontCardViewTop.constant = 150
        }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func againButtonPressed(_ sender: UIButton) {
        avPlayer?.replaceCurrentItem(with: nil)
        deleteRecordedAudio()
        recordingTimeLabel.text = ""
        againButtonPressedLog += 1
        audioBackButton.isHidden = false
        audioFrontButton.isHidden = false
        popUpMessageLabel.isHidden = false
        popUpImage.isHidden = false
        
        // Write log again button
        let cardId = UserDefaults.standard.integer(forKey: "cardId")
        service.writeLogButtonHits(buttonName: "Again", categoryId: cardId) { results in
            switch results {
            case .success(let results):
                print(cardId)
                print("write log again button: \(results)")
            case .failure(let error):
                print(error)
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
        audioBackButton.isHidden = false
        audioFrontButton.isHidden = false
        popUpMessageLabel.isHidden = false
        popUpImage.isHidden = false
        
        // Write log complete button
        let cardId = UserDefaults.standard.integer(forKey: "cardId")

        service.writeLogButtonHits(buttonName: "Easy", categoryId: cardId) { results in
            switch results {
            case .success(let results):
                print(cardId)
                print("write log Complete button: \(results)")
            case .failure(let error):
                print(error)
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
        avPlayer?.replaceCurrentItem(with: nil)
        cardLesson = [CardItems]()
        deleteRecordedAudio()
        dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK: - Render HTML
extension String {
    func htmlAttributedString(fontSize: Int, color: String) -> NSAttributedString? {
        let htmlTemplate = """
            <!doctype html>
            <html>
              <head>
                <style>
                  body {
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    font-size: \(fontSize)px;
                    line-height: 1.4;
                    color: \(color)
                  }
                </style>
              </head>
              <body>
                \(self)
              </body>
            </html>
            """
        
        guard let data = htmlTemplate.data(using: .unicode) else {
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



