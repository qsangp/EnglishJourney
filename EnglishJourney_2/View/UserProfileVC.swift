//
//  UserProfileVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 29/05/2021.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class UserProfileVC: UIViewController {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userProfileInfo: UITextView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var supportButton: UIButton!
    @IBOutlet weak var termsOfUseButton: UIButton!
    
    var cardViewModel: CardViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        updateUI()
    }
    
    func updateUI() {
        versionLabel.text = "EnglishJourney-v1.0"
        supportButton.layer.cornerRadius = 20
        termsOfUseButton.layer.cornerRadius = 20
        
        let userImageURL = UserDefaults.standard.url(forKey: "userImageURL")
        if let url = userImageURL {
            self.userProfileImage.downloaded(from: url)
        }
        
        cardViewModel = CardViewModel()
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            cardViewModel.checkToken(token: accessToken) { (userData, tokenError) in
                if let userData = userData {
                    self.userProfileInfo.text = """
                        Username: \(userData.userNameOrEmail)
                        
                        Email: \(userData.userEmail)
                        """
                }
            }
        }
    }
    
    @IBAction func dismissButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func supportButtonPressed() {
        guard let url = URL(string: "https://www.facebook.com/ieltsvuive/") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func termsOfUseButtonPressed() {
    }
    
    @IBAction func logOutButtonPressed() {
        resetDefaults()
        GIDSignIn.sharedInstance().signOut()
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    
}
