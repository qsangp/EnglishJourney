//
//  CardLessonVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 26/05/2021.
//

import UIKit
import AVFoundation

class CardLessonVC: UIViewController {
    
    let titleLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.00, green: 0.64, blue: 0.64, alpha: 1.00)
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    let statusLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor.systemRed
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    let audioFrontButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "headphones"), for: .normal)
        button.addTarget(self, action: #selector(audioFrontPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let showSampleButton: UIButton = {
        let button = UIButton()
        button.setTitle("Show Sample", for: .normal)
        button.addTarget(self, action: #selector(showSample), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(UIColor(red: 0.00, green: 0.64, blue: 0.64, alpha: 1.00), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let swipeView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
        
    @IBOutlet weak var audioBackButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButon: UIButton!
    @IBOutlet weak var textBackField: UITextView!
    @IBOutlet weak var backCardView: UIView!
    @IBOutlet weak var audioStackView: UIStackView!
    
    
    let againButton: UIButton = {
        let button = UIButton()
        button.setTitle("I forgot, save card", for: .normal)
        button.addTarget(self, action: #selector(againButtonPressed(_:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.systemRed, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("I remembered, finish card", for: .normal)
        button.addTarget(self, action: #selector(completeButtonPressed(_:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor(red: 0.00, green: 0.64, blue: 0.64, alpha: 1.00), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @IBOutlet weak var backToLessonButton: UIButton!
    @IBOutlet weak var audioSlider: UISlider!
        
    // Record
    let recordingTimeLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let recordButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "microphone"), for: .normal)
        button.addTarget(self, action: #selector(start_recording), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let playRecordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Play", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(play_recording), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        label.text = ""
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "left-arrow"), for: .normal)
        button.addTarget(self, action: #selector(backToLessonButtonPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        overrideUserInterfaceStyle = .light

        bindViewModel()
        checkRecordPermission()
        updateUI(autoPlayAudio: true)
        
    }
    // Record Audio
    
    @objc func start_recording() {
        if (isRecording) {
            finishAudioRecording(success: true)
            recordButton.setTitle("Record", for: .normal)
            recordButton.setTitleColor(UIColor.label, for: .normal)
            playRecordButton.isEnabled = true
            playRecordButton.isHidden = false
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
    
    @objc func play_recording() {
        if(isPlaying) {
            audioPlayer.stop()
            recordButton.isEnabled = true
            playRecordButton.setTitle("Play", for: .normal)
            playRecordButton.setTitleColor(UIColor.black, for: .normal)
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
        navigationController?.setNavigationBarHidden(true, animated: false)
        statusLabel.text = ""
        updateUI(autoPlayAudio: true)
    }
    
    func updateUI(autoPlayAudio: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
                
        setupHeader()
        setupAudioFront()
        setupRecord()
        
        backCardView.isHidden = true
        textBackField.isScrollEnabled = true
        textBackField.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                
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
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(completeButtonPressed(_:)))
        swipeLeft.direction = .left
        self.swipeView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(againButtonPressed(_:)))
        swipeRight.direction = .right
        self.swipeView.addGestureRecognizer(swipeRight)
        
        let swipeLeftText = UISwipeGestureRecognizer(target: self, action: #selector(completeButtonPressed(_:)))
        swipeLeftText.direction = .left
        self.textBackField.addGestureRecognizer(swipeLeftText)
        
        let swipeRightText = UISwipeGestureRecognizer(target: self, action: #selector(againButtonPressed(_:)))
        swipeRightText.direction = .right
        self.textBackField.addGestureRecognizer(swipeRightText)
    }
    
    func setupHeader() {
        titleLabel.text = cardData[cardIndex].title.localizedCapitalized
        view.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        
        view.addSubview(backButton)
        backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.addSubview(statusLabel)
        statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        statusLabel.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        
        view.addSubview(swipeView)
        swipeView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height/3).isActive = true
        swipeView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        swipeView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        swipeView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

    }
    
    func setupAudioFront() {
        view.addSubview(audioFrontButton)
        audioFrontButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        audioFrontButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.width/2).isActive = true
        audioFrontButton.widthAnchor.constraint(equalToConstant: view.frame.width/4).isActive = true
        audioFrontButton.heightAnchor.constraint(equalToConstant: view.frame.width/4).isActive = true
        
        view.addSubview(popUpMessageLabel)
        popUpMessageLabel.text = "Playing... \n "
        popUpMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        popUpMessageLabel.topAnchor.constraint(equalTo: audioFrontButton.bottomAnchor, constant: 30).isActive = true
        popUpMessageLabel.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        
        view.addSubview(showSampleButton)
        showSampleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        showSampleButton.topAnchor.constraint(equalTo: popUpMessageLabel.bottomAnchor).isActive = true
        showSampleButton.widthAnchor.constraint(equalToConstant: view.frame.width/3).isActive = true
        showSampleButton.heightAnchor.constraint(equalToConstant: view.frame.width/8).isActive = true
    }
    
    func setupRecord() {
        view.addSubview(recordButton)
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: view.frame.width/8).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: view.frame.width/8).isActive = true
        
        view.addSubview(recordingTimeLabel)
        recordingTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordingTimeLabel.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 10).isActive = true
        recordingTimeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(playRecordButton)
        playRecordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playRecordButton.topAnchor.constraint(equalTo: recordingTimeLabel.bottomAnchor, constant: 10).isActive = true
        playRecordButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        playRecordButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.addSubview(againButton)
        againButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        againButton.trailingAnchor.constraint(equalTo: playRecordButton.leadingAnchor, constant: -5).isActive = true
        againButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70).isActive = true

        view.addSubview(doneButton)
        doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        doneButton.leadingAnchor.constraint(equalTo: playRecordButton.trailingAnchor, constant: 5).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70).isActive = true
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
            
            popUpMessageLabel.text = "Swipe left to finish \nSwipe right to save"
        }
    }
    
    @IBAction func audioSlider(_ sender: Any) {
    }
    
    
    //MARK: - Lesson Section
    
    @objc func showSample() {
        backCardView.fadeIn()
        audioFrontButton.fadeOut()
        popUpMessageLabel.fadeOut()
        showSampleButton.fadeOut()
        statusLabel.fadeOut()
        swipeView.isHidden = true
    }
    
    @IBAction func againButtonPressed(_ sender: UIButton) {
        avPlayer?.replaceCurrentItem(with: nil)
        deleteRecordedAudio()
        recordingTimeLabel.text = ""
        playRecordButton.setTitle("Play", for: .normal)
        playRecordButton.setTitleColor(UIColor.black, for: .normal)
        againButtonPressedLog += 1
        backCardView.fadeOut()
        audioFrontButton.fadeIn()
        popUpMessageLabel.fadeIn()
        showSampleButton.fadeIn()
        statusLabel.text = "Card was saved, \(cardData.count-1) left"
        statusLabel.fadeIn()
        swipeView.isHidden = false

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
        playRecordButton.setTitle("Play", for: .normal)
        playRecordButton.setTitleColor(UIColor.black, for: .normal)
        completeButtonPressedLog += 1
        backCardView.fadeOut()
        audioFrontButton.fadeIn()
        popUpMessageLabel.fadeIn()
        showSampleButton.fadeIn()
        statusLabel.text = "Card was finished, \(cardData.count-1) left"
        statusLabel.fadeIn()
        swipeView.isHidden = false

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




