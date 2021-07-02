//
//  CardLessonVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 26/05/2021.
//

import UIKit
import AVFoundation

class CardLessonVC: UIViewController {
    
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
    var viewModel: CardViewModel!
    var cardData = [CardData]()
    var temporaryCardData = [CardData]()
    var cardIndex = 0
    var currentCardId = 0
    
    let popUpMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Double tap to Show sample \nSwipe left ← to click Done \nSwipe right → to click Again"
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
        navigationController?.setNavigationBarHidden(false, animated: false)

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
        currentCardId = viewModel.getCurrentCardId()
        let data = viewModel.getCardData(cardId: currentCardId)
        if UserDefaults.standard.bool(forKey: "randomSwitch") {
            cardData = data.shuffled()
            temporaryCardData = data.shuffled()
        } else {
            cardData = data
            temporaryCardData = data
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)

    }
    
    func updateUI(autoPlayAudio: Bool) {
        overrideUserInterfaceStyle = .light
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.overrideUserInterfaceStyle = .light
        navigationItem.title = cardData[cardIndex].title.localizedCapitalized
        backCardView.isHidden = true
        textBackField.isScrollEnabled = true
        
        textBackField.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        showHideButton.layer.cornerRadius = 10
        againButton.layer.cornerRadius = 10
        completeButton.layer.cornerRadius = 10
        
        showHideButton.setTitle("Show Sample", for: .normal)
        showHideButton.setTitleColor(.label, for: .normal)
        
        // Render HTML
        let htmlString = cardData[cardIndex].backText
        
        textBackField.attributedText = htmlString.htmlAttributedString(fontSize: 16)

        
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
        cardData = temporaryCardData
    }
    
    //MARK: - Audio Section
    
    @IBAction func audioFrontPressed(_ sender: UIButton) {
        let baseURL = "https://app.ielts-vuive.com/data/audio/"
        let id = String(cardData[cardIndex].id)
        let audioName = cardData[cardIndex].audioFrontName
        
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
        let id = String(cardData[cardIndex].id)
        let audioName = cardData[cardIndex].audioBackName
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
            
        } else {
            showHideButton.setTitle("Show Sample", for: .normal)
            
            backCardView.isHidden = true
            audioFrontButton.isHidden = false
            popUpMessageLabel.isHidden = false
            popUpImage.isHidden = false
            
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
        viewModel.writeLogButton(.again)

        switch cardIndex {
        case cardData.count - 1:
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
        
        viewModel.writeLogButton(.done)
        
        if cardIndex == 0 && cardData.count == 1 {
            chartData = ChartData(againButtonPressedLog: againButtonPressedLog, completeButtonPressedLog: completeButtonPressedLog)
            
            // Reset Card and Show Complete screen
            resetCardLesson()
            updateUI(autoPlayAudio: false)
            
            performSegue(withIdentifier: "GoToLessonCompleteVC", sender: nil)
            
        } else if cardIndex == cardData.count - 1 {
            cardData.remove(at: cardIndex)
            cardIndex = 0
            updateUI(autoPlayAudio: true)
        } else {
            cardData.remove(at: cardIndex)
            updateUI(autoPlayAudio: true)
        }
    }
    
    @IBAction func backToLessonButtonPressed(_ sender: UIButton) {
        avPlayer?.replaceCurrentItem(with: nil)
        cardData = [CardData]()
        deleteRecordedAudio()
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToLessonCompleteVC" {
            if let vc = segue.destination as? LessonCompleteVC {
                vc.viewModel = viewModel
                vc.cardCompleteData = self.cardData
                vc.clickedData = self.chartData
            }
        }
    }
}




