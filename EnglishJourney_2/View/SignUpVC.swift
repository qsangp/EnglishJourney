//
//  SignUpVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 29/05/2021.
//

import UIKit

class SignUpVC: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var messageAlert: UILabel!
    
    var cardViewModel: CardViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField()
        updateUI()
    }
    
    func updateUI() {
        signUpButton.layer.cornerRadius = 20
        cardViewModel = CardViewModel()
    }
    
    private func configureTextField() {
        nameTextField.delegate = self
        surnameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        retypePasswordTextField.delegate = self
    }
    @IBAction func backToLoginPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        if let name = nameTextField.text,
           let surname = surnameTextField.text,
           let email = emailTextField.text,
           let password = passwordTextField.text,
           let retypePassword = retypePasswordTextField.text {
            if password == retypePassword {
                cardViewModel.createUser(name: name, surname: surname, username: name + surname, email: email, password: password) {
                    print("success")
                }
            } else {
                messageAlert.text = "Passwords don't match!"
            }
        }
    }
    

}
