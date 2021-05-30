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
    @IBOutlet weak var errorMessage: UILabel!
    
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
    
    private func clearTextField() {
        nameTextField.text?.removeAll()
        surnameTextField.text?.removeAll()
        emailTextField.text?.removeAll()
        passwordTextField.text?.removeAll()
        retypePasswordTextField.text?.removeAll()
    }
    
    @IBAction func backToLoginPressed(_ sender: UIButton) {
        clearTextField()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        sender.preventRepeatedPresses()
                
        if let name = nameTextField.text,
           let surname = surnameTextField.text,
           let email = emailTextField.text,
           let password = passwordTextField.text,
           let retypePassword = retypePasswordTextField.text {
            
            if name.count > 0, surname.count > 0, email.count > 0, password.count >= 6, password == retypePassword {
                cardViewModel.createUser(name: name, surname: surname, username: name + " " + surname, email: email, password: password) {
                    self.clearTextField()
                    self.dismiss(animated: true, completion: nil)

                }
            } else {
                errorMessage.text = "All fields are required! \nPasswords don't match or less than 6 characters"
            }
            
        }
            
    }
    
    func checkError() {
        if let error = cardViewModel.errorMessage {
            self.errorMessage.text = error
        }
    }
    
    
}


