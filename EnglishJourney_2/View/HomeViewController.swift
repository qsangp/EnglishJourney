//
//  HomeViewController.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/06/2021.
//

import UIKit
import GoogleSignIn
import Kingfisher
import UserNotifications

class HomeViewController: UIViewController {
    
    //Data source
    var viewModel: CardViewModel!
    let service = Service()
    var parentId: Int!
        
    private var observer: NSObjectProtocol?
    
    fileprivate let whatToLearnCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    fileprivate let randomCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    let titleLable: UILabel = {
        let title = UILabel()
        title.text = "Hello"
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.numberOfLines = 0
        return title
    }()
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "MyTableViewCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = UITableViewCell.SeparatorStyle.none
        return tv
    }()
    
    let progressHUD = ProgressHUD(text: "Updating...")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        let tabbarController = tabBarController as! CustomTabBarVC
        viewModel = tabbarController.viewModel
        
        observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkAuthentication), name: NSNotification.Name(rawValue: "PeformAfterPresenting"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(finishLoadingData), name: NSNotification.Name(rawValue: "PeformAfterLoadingData"), object: nil)
                
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75).isActive = true
        tableView.isUserInteractionEnabled = false
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)

        UserDefaults.standard.setValue(false, forKey: "removeCardReview")
        tableView.reloadData()
    }
    
    // Update UI
    func updateUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.barTintColor = .white
        
        self.view.addSubview(progressHUD)
        progressHUD.isHidden = false
        checkAuthentication()
        
    }
    
    // Check Authentication
    @objc func checkAuthentication() {
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            service.checkToken(token: accessToken) { [weak self] results in
                switch results {
                case .success(let user):
                    UserDefaults.standard.setValue(user.id, forKey: "userId")
                    UserDefaults.standard.setValue(user.email, forKey: "userEmail")
                    print("check Authentication successfully")
                    DispatchQueue.main.async {
                        self?.viewModel.needPerformAction = { [weak self] in
                            self?.whatToLearnCollectionView.reloadData()
                            self?.randomCollectionView.reloadData()
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PeformAfterLoadingData"), object: nil)
                        }
                        self?.viewModel.requestCategory()
                    }
                case .failure(let error):
                    print("checkToken error: \(error)")
                    DispatchQueue.main.async {
                        self?.showLoginVCFromHomeVC()
                    }
                }
            }
        } else {
            print("Token is expired -> User must login")
            DispatchQueue.main.async {
                self.showLoginVCFromHomeVC()
            }
        }
    }
    
    @objc func finishLoadingData() {
        tableView.isUserInteractionEnabled = true
        progressHUD.isHidden = true
    }
    
    @objc func tapRandomSwitch(_ sender: UISwitch!) {
        
        if sender.isOn {
            UserDefaults.standard.setValue(true, forKey: "randomSwitch")
        } else {
            UserDefaults.standard.setValue(false, forKey: "randomSwitch")
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HeaderView()
        header.backgroundColor = .white
        switch section {
        case 0:
            header.configure(mainLabel: "   What to learn", addSecondLabel: false, addSwitch: false, addRefresh: true)
            header.refreshButton.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
            header.refreshButton.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20).isActive = true
            return header
        case 1:
            header.configure(mainLabel: "   Random", addSecondLabel: false, addSwitch: true, addRefresh: false)
            return header
        case 2:
            header.configure(mainLabel: "   To Review", addSecondLabel: true, addSwitch: false, addRefresh: false)
            let data = viewModel.getCardToReview()
            if data.count == 0 {
                header.secondLabel.isHidden = true
            } else {
                header.secondLabel.isHidden = false
                header.secondLabel.text = "\(data.count)"
            }
            return header
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1:
            return 1
        case 2:
            let data = viewModel.getCardToReview()
            if data.count == 0 {
                return 1
            } else {
                return data.count
            }
        default:
            return 0
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell") as! MyTableViewCell
        cell.selectionStyle = .none
        cell.viewModel = viewModel

        switch indexPath.section {
        case 0:
            cell.contentView.addSubview(whatToLearnCollectionView)
            whatToLearnCollectionView.delegate = self
            whatToLearnCollectionView.dataSource = self
            whatToLearnCollectionView.backgroundColor = .white
            whatToLearnCollectionView.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            whatToLearnCollectionView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10).isActive = true
            whatToLearnCollectionView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10).isActive = true
            whatToLearnCollectionView.heightAnchor.constraint(equalToConstant: cell.contentView.frame.width/1.2).isActive = true
            return cell
        case 1:
            cell.contentView.addSubview(randomCollectionView)
            randomCollectionView.delegate = self
            randomCollectionView.dataSource = self
            randomCollectionView.backgroundColor = .white
            randomCollectionView.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            randomCollectionView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10).isActive = true
            randomCollectionView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10).isActive = true
            randomCollectionView.heightAnchor.constraint(equalToConstant: cell.contentView.frame.width/2.5).isActive = true
            return cell
        case 2:
            let card = viewModel.getCardToReview()
            if card.count == 0 {
                cell.setupNoCardReviewCell()
            } else {
                let data = card[indexPath.row]
                cell.setupLessonCell()
                cell.bindDataToReview(data: data)
                if let log = viewModel.getCardLog(cardId: data.id) {
                    cell.secondTitleLable.text = log.timeAgoDisplay()
                }
            }
            return cell
        default:
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let data = viewModel.getCardToReview()[indexPath.row]
            viewModel.saveCurrentCardId(cardId: data.id)
            UserDefaults.standard.setValue(true, forKey: "removeCardReview")
            self.performSegue(withIdentifier: "showRandomCardData", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 250
        case 2:
            if indexPath.row > 5 {
                return 0
            } else {
                return 120
            }
        default:
            return 120
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case whatToLearnCollectionView:
            return CGSize(width: collectionView.frame.width/1.8, height: collectionView.frame.width/2)
        case randomCollectionView:
            return CGSize(width: collectionView.frame.width/4, height: 70)
        default:
            return CGSize(width: collectionView.frame.width/1.8, height: collectionView.frame.width/2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case whatToLearnCollectionView:
            return viewModel.numberOfRowsInSection(section: section)
        case randomCollectionView:
            return viewModel.numberOfRowsInSection(section: section)
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = viewModel.cellForRowAt(indexPath: indexPath)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        cell.viewModel = viewModel
        
        switch collectionView {
        case whatToLearnCollectionView:
            cell.setupWhatToLearn()
            cell.bindData(data: data)
            return cell
        case randomCollectionView:
            cell.setupRandom()
            cell.bindDataForRandom(data: data)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = viewModel.cellForRowAt(indexPath: indexPath)
        viewModel.saveCurrentCategoryId(categoryId: data.id)
        viewModel.saveCurrentCategoryTitle(data.title)
        UserDefaults.standard.setValue(data.id, forKey: "currentParentId")
        UserDefaults.standard.setValue(data.title, forKey: "currentParentTitle")

        switch collectionView {
        case whatToLearnCollectionView:
            self.performSegue(withIdentifier: "GoToLessonVC", sender: nil)
            
        case randomCollectionView:
            viewModel.requestLessons(parentId: data.id)
            
            let items = viewModel.getCardCategoryItems()
            guard items.count > 0 else {return}
            let randomIndex = Int.random(in: 1..<items.count)
            let randomCardId = items[randomIndex].id
            viewModel.saveCurrentCardId(cardId: randomCardId)
            self.performSegue(withIdentifier: "showRandomCardData", sender: nil)

        default:
            print("")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "GoToLessonVC":
            if let vc = segue.destination as? LessonVC {
                vc.viewModel = viewModel
                vc.bindViewModel()
            }
        case "showRandomCardData":
            if let destVC = segue.destination as? UINavigationController,
                let targetController = destVC.topViewController as? CardLessonVC {
                destVC.modalPresentationStyle = .fullScreen
                targetController.viewModel = viewModel
            }
        default:
            print("no segue")
        }
        
    }

}

class HeaderView: UIView {
    
    private var label: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    public var secondLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 130, y: 10, width: 20, height: 20))
        label.text = "0"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .white
        label.layer.masksToBounds = true
        label.backgroundColor = .systemRed
        label.layer.cornerRadius = label.frame.width/2
        return label
    }()
    
    let randomSwitch: UISwitch = {
        let randomSwitch = UISwitch(frame: CGRect(x: 120, y: 4, width: 0, height: 0))
        randomSwitch.isOn = true
        randomSwitch.addTarget(self, action: #selector(HomeViewController.tapRandomSwitch(_:)), for: .valueChanged)
        return randomSwitch
    }()
    
    let refreshButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Update Lessons", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(UIColor(red: 0.00, green: 0.64, blue: 0.64, alpha: 1.00), for: .normal)
        button.addTarget(self, action: #selector(HomeViewController.checkAuthentication), for: .touchUpInside)
        return button
    }()
    
    var switchLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 175, y: -4, width: 150, height: 50))
        label.text = "shuffle lessons"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
        
    public func configure(mainLabel: String, addSecondLabel: Bool, addSwitch: Bool, addRefresh: Bool) {
        label.text = "\(mainLabel)"
        addSubview(label)
        if addSwitch {
            addSubview(randomSwitch)
            addSubview(switchLabel)
        }
        
        if UserDefaults.standard.bool(forKey: "randomSwitch") {
            randomSwitch.isOn = true
        } else {
            randomSwitch.isOn = false
        }
        
        if addSecondLabel {
            addSubview(secondLabel)
        }
        
        if addRefresh {
            addSubview(refreshButton)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
}

class CustomCell: UICollectionViewCell {
    
    var viewModel: CardViewModel!
        
    fileprivate let thumbnailImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    fileprivate let categoryTitle: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "IELTS Speaking Task 1"
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return title
    }()
    
    fileprivate let authorTitle: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Author: Mr.Sang"
        title.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        title.textColor = UIColor.systemGray
        return title
    }()
    
    fileprivate let randomButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.cornerRadius = 10
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
    }
    
    func setupWhatToLearn() {
        contentView.addSubview(thumbnailImage)
        
        thumbnailImage.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        thumbnailImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        thumbnailImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        thumbnailImage.widthAnchor.constraint(equalToConstant: contentView.frame.width/1.2).isActive = true
        thumbnailImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50).isActive = true

        contentView.addSubview(categoryTitle)
        categoryTitle.topAnchor.constraint(equalTo: thumbnailImage.bottomAnchor, constant: 10).isActive = true
        categoryTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        categoryTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        contentView.addSubview(authorTitle)
        authorTitle.topAnchor.constraint(equalTo: categoryTitle.bottomAnchor, constant: 5).isActive = true
        authorTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        authorTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        authorTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    func setupRandom() {
        contentView.addSubview(randomButton)
        randomButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        randomButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        randomButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        randomButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(data: CardCategory) {
        categoryTitle.text = data.title.localizedCapitalized

        let urlFile = data.title.localizedLowercase.replacingOccurrences(of: " ", with: "-")
        guard let url = URL(string: "https://app.ielts-vuive.com/data/lesson/image/\(urlFile).jpg?v=") else {return}
        
        viewModel.saveCardThumbnailImage(cardId: data.id, url: url)

        let resource = ImageResource(downloadURL: url, cacheKey: urlFile)
        thumbnailImage.kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.2))])
    }
    
    func bindDataForRandom(data: CardCategory) {
        randomButton.setTitle(data.title.localizedCapitalized, for: .normal)
        randomButton.setTitleColor(.black, for: .normal)
        randomButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        randomButton.titleLabel?.numberOfLines = 0
        randomButton.titleLabel?.textAlignment = .center
    }
}
