//
//  LogInVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 29/05/2021.
//

import UIKit
import QuartzCore
import GoogleSignIn

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
    @IBOutlet weak var googleLoginButton: UIView!
    @IBOutlet weak var googleButtonLabel: UIButton!
    
    
    var viewModel: CardViewModel!
    let service = Service()
    
    deinit {
        print("Login VC has no retain cycle")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        configureTextField()
        updateUI()
        checkAuthentication()
    }
    
    func updateUI() {
        hideKeyboardWhenTappedAround()
        mainTitle.setTextWithTypeAnimation(typedText: "English Journey", characterDelay: 10)
        emailTextField.layer.masksToBounds = true
        emailTextField.layer.cornerRadius = 5
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
        passwordTextField.layer.masksToBounds = true
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Mật khẩu",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
        loginButton.layer.cornerRadius = 5
                
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    private func bindViewModel() {
        viewModel = CardViewModel()
    }
    
    func createNewUser(name: String, email: String) {
        service.createUser(name: name, email: email) { [weak self] errorMessage in
            if errorMessage == nil {
                self?.fetchLogin(email: email, password: name)
            } else {
                print(errorMessage!)
                self?.fetchLogin(email: email, password: name)
            }
        }
    }
    
    func fetchLogin(email: String, password: String) {
        service.fetchLogin(email: email, password: password + "7nQ-ij") { [weak self] results in
            switch results {
            case .success(let results):
                UserDefaults.standard.setValue(results, forKey: "accessToken")
                DispatchQueue.main.async {
                    self?.checkAuthentication()
                }
            case .failure(let error):
                print("login failed: \(error.localizedDescription)")
                self?.viewModel.needShowError = { [weak self] error in
                    self?.showError(error: error)
                }
            }
        }
    }
    
    private func configureTextField() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func clearTextField() {
        emailTextField.text?.removeAll()
        passwordTextField.text?.removeAll()
    }
    
    private func showError(error: ErrorMessage) {
        let alert = UIAlertController(title: "Error", message: error.rawValue, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnGooglePressed(_ sender: UIButton) {
        sender.preventRepeatedPresses()
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        sender.preventRepeatedPresses()
        
        do {
            try login()
            let email = emailTextField.text!
            let password = passwordTextField.text!
            
            service.fetchLogin(email: email, password: password) { [weak self] results in
                switch results {
                case .success(_):
                    self?.checkAuthentication()
                case .failure(_):
                    self?.viewModel.needShowError = { [weak self] error in
                        self?.showError(error: error)
                    }
                }
            }
        } catch LoginError.incompleteForm {
            Alert.showBasic(title: "Incomplete Form", message: "Please fill out both email and password fields", vc: self)
        } catch LoginError.incorrectPasswordLength {
            Alert.showBasic(title: "Password Too Short", message: "Password should be at least 6 characters", vc: self)
        } catch {
            Alert.showBasic(title: "Unable To Login", message: "Something went wrong. Please try again later...", vc: self)
        }
        
    }
    
    // Check Authentication
    func checkAuthentication() {
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            service.checkToken(token: accessToken) { [weak self] results in
                switch results {
                case .success(let results):
                    UserDefaults.standard.setValue(results.userEmail, forKey: "userEmail")
                    UserDefaults.standard.setValue(results.id, forKey: "userId")
                    print("check Authentication successfully")
                    self?.performSegue(withIdentifier: "LogInSuccess", sender: nil)
                case .failure(let error):
                    print("checkToken error: \(error)")
                }
            }
        } else {
            print("Token is expired -> User must login")
        }
    }
    
    // Throw error login
    func login() throws {
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if email.isEmpty || password.isEmpty {
            throw LoginError.incompleteForm
        }
        if password.count < 6 {
            throw LoginError.incorrectPasswordLength
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

extension LogInVC: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Swift.Error!) {
        if error != nil {
            print(error.localizedDescription)
            
        } else {
            if GIDSignIn.sharedInstance().hasPreviousSignIn() {
                if let user = GIDSignIn.sharedInstance().currentUser {
                    if let email = user.profile.email,
                       let userName = email.components(separatedBy: CharacterSet(charactersIn: ("@0123456789"))).first {
                        if user.profile.hasImage {
                            let userImageURL = user.profile.imageURL(withDimension: 500)
                            UserDefaults.standard.set(userImageURL, forKey: "userImageURL")
                        }
                        let displayName = user.profile.name
                        print("welcome \(displayName!)")
                        UserDefaults.standard.setValue(displayName, forKey: "userName")
                        createNewUser(name: userName, email: email)
                    }
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Swift.Error!) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
}




