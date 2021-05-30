//
//  LogInVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 29/05/2021.
//

import UIKit
import QuartzCore

class LogInVC: UIViewController {
    
    enum LoginError: Swift.Error {
        case incompleteForm
        case invalidEmail
        case incorrectPasswordLength
        case incorrectEmailOrPassword
        case emailAlreadyInUse
    }
    
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    var cardViewModel: CardViewModel!
    
    let loginSuccessView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let popUpMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Login Successfully!"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        return label
    }()
    
    let popUpImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "check"))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField()
        setupLogInSuccessView()
        updateUI()
        
    }
    func updateUI() {
        hideKeyboardWhenTappedAround()
        
        emailTextField.layer.cornerRadius = 20
        passwordTextField.layer.cornerRadius = 20
        loginButton.layer.cornerRadius = 20
        
        cardViewModel = CardViewModel()
        checkAuthentication()

    }
    
    func setupLogInSuccessView() {
        
        view.addSubview(loginSuccessView)
        loginSuccessView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginSuccessView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loginSuccessView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loginSuccessView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        loginSuccessView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        loginSuccessView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        view.addSubview(popUpImage)
        popUpImage.centerXAnchor.constraint(equalTo: loginSuccessView.centerXAnchor).isActive = true
        popUpImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        popUpImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(popUpMessageLabel)
        popUpMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        popUpMessageLabel.centerXAnchor.constraint(equalTo: loginSuccessView.centerXAnchor).isActive = true
        popUpMessageLabel.centerYAnchor.constraint(equalTo: loginSuccessView.centerYAnchor).isActive = true
        popUpMessageLabel.topAnchor.constraint(equalTo: popUpImage.bottomAnchor, constant: 10).isActive = true
        popUpMessageLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        loginSuccessView.isHidden = true
        popUpImage.isHidden = true
        popUpMessageLabel.isHidden = true
    }
    
    private func configureTextField() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.text = "hongngoc@gmail.com"
        passwordTextField.text = "1234567"
    }
    
    private func clearTextField() {
        emailTextField.text?.removeAll()
        passwordTextField.text?.removeAll()
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        self.clearTextField()
        performSegue(withIdentifier: "GoToSignUp", sender: self)
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        sender.preventRepeatedPresses()
        do {
            try login()
            let email = emailTextField.text!
            let password = passwordTextField.text!
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let error = self.cardViewModel.errorMessage
                if error == "The data couldn’t be read because it is missing." {
                    Alert.showBasic(title: "Incorrect Email Or Password", message: "Check your email and password again", vc: self)
                    self.cardViewModel.errorMessage = ""
                }
            }
            
            cardViewModel.fetchLogIn(username: email, password: password) {
                self.clearTextField()
                self.loginSuccessView.isHidden = false
                self.popUpImage.isHidden = false
                self.popUpMessageLabel.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.performSegue(withIdentifier: "LogInSuccess", sender: self)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.loginSuccessView.isHidden = true
                    self.popUpImage.isHidden = true
                    self.popUpMessageLabel.isHidden = true
                    self.cardViewModel.errorMessage = ""
                    self.clearTextField()
                }
            }
        } catch LoginError.incompleteForm {
            Alert.showBasic(title: "Incomplete Form", message: "Please fill out both email and password fields", vc: self)
        } catch LoginError.invalidEmail {
            Alert.showBasic(title: "Invalid Email Format", message: "Please make sure you format your email correctly", vc: self)
        } catch LoginError.incorrectPasswordLength {
            Alert.showBasic(title: "Password Too Short", message: "Password should be at least 6 characters", vc: self)
//        } catch LoginError.incorrectEmailOrPassword {
//            Alert.showBasic(title: "Incorrect Email Or Password", message: "Check your email and password again", vc: self)
//            cardViewModel.errorMessage = ""
        } catch {
            Alert.showBasic(title: "Unable To Login", message: "Appologies, something went wrong. Please try again later...", vc: self)
            cardViewModel.errorMessage = ""

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

// Throw error login
    
    func login() throws {
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if email.isEmpty || password.isEmpty {
            throw LoginError.incompleteForm
        }
        
        if !email.inValidEmail {
            throw LoginError.invalidEmail
        }
        
        if password.count < 6 {
            throw LoginError.incorrectPasswordLength
        }
        
//        if error == "The data couldn’t be read because it is missing." {
//            throw LoginError.incorrectEmailOrPassword
//        }
//
//        if error == "[Identity.Duplicate email]" {
//            throw LoginError.emailAlreadyInUse
//        }
        
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


