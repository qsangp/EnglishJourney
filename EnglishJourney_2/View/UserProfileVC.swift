//
//  UserProfileVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 29/05/2021.
//

import UIKit
import GoogleSignIn
import Kingfisher

class UserProfileVC: UIViewController {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userProfileInfo: UITextView!
    @IBOutlet weak var supportButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    var viewModel: CardViewModel!
    
    deinit {
        print("Userprofile VC has no retain cycle")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: "PeformAfterPresenting"), object: nil)
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
        
    @objc func updateUI() {
        overrideUserInterfaceStyle = .light
        navigationController?.setNavigationBarHidden(true, animated: false)
                        
        let userImageURL = UserDefaults.standard.url(forKey: "userImageURL")
        if let url = userImageURL {
            self.userProfileImage.kf.setImage(with: url)
            userProfileImage.contentMode = .scaleAspectFill
            userProfileImage.layer.borderWidth = 1.0
            userProfileImage.layer.masksToBounds = false
            userProfileImage.layer.borderColor = UIColor.white.cgColor
            userProfileImage.layer.cornerRadius = userProfileImage.frame.size.width / 2
            userProfileImage.clipsToBounds = true
        }
        guard let userName = UserDefaults.standard.string(forKey: "userName"),
              let userEmail = UserDefaults.standard.string(forKey: "userEmail") else {return}
        self.userProfileInfo.text = """
                        \(userName)
                        \(userEmail)
                        """
    }
    
    @IBAction func supportButtonPressed() {
        guard let url = URL(string: "https://www.facebook.com/ieltsvuive/") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func logOutButtonPressed() {        
        resetDefaults()
        KeychainItem.deleteUserIdentifierFromKeychain()
        GIDSignIn.sharedInstance().signOut()
        self.showLoginViewController()
    }
}
