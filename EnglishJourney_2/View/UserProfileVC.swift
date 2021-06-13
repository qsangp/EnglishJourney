//
//  UserProfileVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 29/05/2021.
//

import UIKit
import GoogleSignIn

class UserProfileVC: UIViewController {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userProfileInfo: UITextView!
    @IBOutlet weak var supportButton: UIButton!
    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    var cardViewModel: CardViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        updateUI()
    }
    
    func updateUI() {
        
        let userImageURL = UserDefaults.standard.url(forKey: "userImageURL")
        if let url = userImageURL {
            self.userProfileImage.downloaded(from: url)
        }
        guard let userName = UserDefaults.standard.string(forKey: "userName"),
              let userEmail = UserDefaults.standard.string(forKey: "userEmail") else {return}
        self.userProfileInfo.text = """
                        Username: \(userName)
                        
                        Email: \(userEmail)
                        """
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
        print("User has signed out!")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    
}
