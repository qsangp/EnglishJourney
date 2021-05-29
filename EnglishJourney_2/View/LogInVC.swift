//
//  LogInVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 29/05/2021.
//

import UIKit

class LogInVC: UIViewController {
    
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var cardViewModel: CardViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        updateUI()
        
    }
    func updateUI() {
        hideKeyboardWhenTappedAround()
        usernameTextField.layer.cornerRadius = 20
        passwordTextField.layer.cornerRadius = 20
        loginButton.layer.cornerRadius = 20
        
        cardViewModel = CardViewModel()
        checkAuthentication()

    }
    
    private func configureTextField() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        
        if let username = usernameTextField.text, let password = passwordTextField.text {
            cardViewModel.fetchLogIn(username: username, password: password) {
                
                self.performSegue(withIdentifier: "LogInSuccess", sender: nil)
            }
        }
    }
    
    @IBAction func skipPressed(_ sender: UIButton) {
        
    }
    
// Check Authentication
    func checkAuthentication() {
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            cardViewModel.checkToken(token: accessToken) { userData in
                self.performSegue(withIdentifier: "LogInSuccess", sender: nil)
            }
        }
    }
}

extension UIViewController: UITextFieldDelegate {

    @objc func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}


