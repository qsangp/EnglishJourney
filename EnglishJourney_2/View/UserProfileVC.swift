//
//  UserProfileVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 29/05/2021.
//

import UIKit

class UserProfileVC: UIViewController {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userProfileInfo: UITextView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var supportButton: UIButton!
    @IBOutlet weak var termsOfUseButton: UIButton!

    var cardViewModel: CardViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        versionLabel.text = "EnglishJourney-v1.0"
        supportButton.layer.cornerRadius = 20
        termsOfUseButton.layer.cornerRadius = 20
        
        cardViewModel = CardViewModel()
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            cardViewModel.checkToken(token: accessToken) { userData in
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
    }
    
    @IBAction func termsOfUseButtonPressed() {
    }
    
    @IBAction func logOutButtonPressed() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

    }


}
