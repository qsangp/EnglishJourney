//
//  LogInVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 29/05/2021.
//

import UIKit
import QuartzCore
import GoogleSignIn
import NVActivityIndicatorView

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
    
    var cardViewModel: CardViewModel!
    
    let loadingWhiteView: UIView = {
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
    
    let activityIndicator: NVActivityIndicatorView = {
        let loading = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: UIColor(red: 0.58, green: 0.84, blue: 0.83, alpha: 1.00), padding: 0)
        loading.translatesAutoresizingMaskIntoConstraints = false
        return loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        configureTextField()
        setupView()
        setUpAnimation()
        updateUI()
        
    }
    func updateUI() {
        hideKeyboardWhenTappedAround()
        
        emailTextField.layer.cornerRadius = 20
        passwordTextField.layer.cornerRadius = 20
        loginButton.layer.cornerRadius = 20
        
        googleLoginButton.layer.borderWidth = 1.0
        googleLoginButton.layer.borderColor = UIColor.darkGray.cgColor
        googleLoginButton.layer.cornerRadius = 20
        
        cardViewModel = CardViewModel()
        
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        
        checkAuthentication()
    }
    
    func setUpAnimation() {
        
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 40),
            activityIndicator.heightAnchor.constraint(equalToConstant: 40),
            activityIndicator.topAnchor.constraint(equalTo: googleLoginButton.bottomAnchor, constant: 20)
        ])
        activityIndicator.stopAnimating()
    }
    
    func setupView() {
        
        view.addSubview(loadingWhiteView)
        NSLayoutConstraint.activate([
            loadingWhiteView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingWhiteView.centerYAnchor.constraint(equalTo: view.centerYAnchor), loadingWhiteView.topAnchor.constraint(equalTo: view.topAnchor), loadingWhiteView.bottomAnchor.constraint(equalTo: view.bottomAnchor), loadingWhiteView.leftAnchor.constraint(equalTo: view.leftAnchor), loadingWhiteView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        view.addSubview(popUpImage)
        NSLayoutConstraint.activate([
            popUpImage.centerXAnchor.constraint(equalTo: loadingWhiteView.centerXAnchor),
            popUpImage.widthAnchor.constraint(equalToConstant: 100),
            popUpImage.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        view.addSubview(popUpMessageLabel)
        
        popUpMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popUpMessageLabel.centerXAnchor.constraint(equalTo: loadingWhiteView.centerXAnchor),
            popUpMessageLabel.centerYAnchor.constraint(equalTo: loadingWhiteView.centerYAnchor),
            popUpMessageLabel.topAnchor.constraint(equalTo: popUpImage.bottomAnchor, constant: 10),
            popUpMessageLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        loadingWhiteView.isHidden = true
        popUpImage.isHidden = true
        popUpMessageLabel.isHidden = true
    }
    
    private func configureTextField() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func clearTextField() {
        emailTextField.text?.removeAll()
        passwordTextField.text?.removeAll()
    }
    
    @IBAction func btnGooglePressed(_ sender: UIButton) {
        sender.preventRepeatedPresses()
        GIDSignIn.sharedInstance().signIn()
        activityIndicator.startAnimating()
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        sender.preventRepeatedPresses()
        activityIndicator.startAnimating()
        
        do {
            try login()
            let email = emailTextField.text!
            let password = passwordTextField.text!
            
            self.cardViewModel.fetchLogIn(username: email, password: password) { error in
                
                if error != nil {
                    Alert.showBasic(title: "Unable To Login", message: "Something went wrong. Please try again later...", vc: self)
                    self.activityIndicator.stopAnimating()
                    
                } else {
                    self.loadingWhiteView.isHidden = false
                    self.popUpImage.isHidden = false
                    self.popUpMessageLabel.isHidden = false
                    
                    self.performSegue(withIdentifier: "LogInSuccess", sender: self)
                    self.activityIndicator.stopAnimating()
                    self.loadingWhiteView.isHidden = true
                    self.popUpImage.isHidden = true
                    self.popUpMessageLabel.isHidden = true
                }
            }
            
        } catch LoginError.incompleteForm {
            Alert.showBasic(title: "Incomplete Form", message: "Please fill out both email and password fields", vc: self)
        } catch LoginError.invalidEmail {
            Alert.showBasic(title: "Invalid Email Format", message: "Please make sure you format your email correctly", vc: self)
        } catch LoginError.incorrectPasswordLength {
            Alert.showBasic(title: "Password Too Short", message: "Password should be at least 6 characters", vc: self)
        } catch {
            Alert.showBasic(title: "Unable To Login", message: "Something went wrong. Please try again later...", vc: self)
            cardViewModel.errorMessage = ""
            
        }
        
    }
    
    // Check Authentication
    func checkAuthentication() {
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            cardViewModel.checkToken(token: accessToken) { (userData, tokenError) in
                if tokenError != nil {
                    print("User must login")
                } else {
                    self.performSegue(withIdentifier: "LogInSuccess", sender: nil)
                }
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
            self.activityIndicator.stopAnimating()
            
        } else {
            if GIDSignIn.sharedInstance().hasPreviousSignIn() {
                if let user = GIDSignIn.sharedInstance().currentUser {
                    if let email = user.profile.email,
                       let username = email.components(separatedBy: CharacterSet(charactersIn: ("@0123456789"))).first,
                       let id = user.userID {
                        if user.profile.hasImage {
                            let userImageURL = user.profile.imageURL(withDimension: 500)
                            UserDefaults.standard.set(userImageURL, forKey: "userImageURL")
                        }
                        print(email)
                        print(id)
                        
                        // Try to login
                        print("Try to login")
                        self.cardViewModel.fetchLogIn(username: email, password: username + "7nQ-ij") { error in
                            
                            if error != nil {
                                // User didn't exist -> create new user
                                print("User didn't exist -> create new user")
                                self.cardViewModel.createUser(name: username, surname: username, username: username, email: email, password: username + "7nQ-ij") { error in
                                    
                                    if error != nil {
                                        Alert.showBasic(title: "Unable To Create New User", message: "\(error!). Please try again later...", vc: self)
                                        
                                    } else {
                                        self.cardViewModel.fetchLogIn(username: email, password: username + "7nQ-ij") { error in
                                            
                                            if error != nil {
                                                print("Failed to login new user")
                                                
                                            } else {
                                                self.loadingWhiteView.isHidden = false
                                                self.popUpImage.isHidden = false
                                                self.popUpMessageLabel.isHidden = false
                                                
                                                self.performSegue(withIdentifier: "LogInSuccess", sender: self)
                                                self.activityIndicator.stopAnimating()
                                                self.loadingWhiteView.isHidden = true
                                                self.popUpImage.isHidden = true
                                                self.popUpMessageLabel.isHidden = true
                                            }
                                        }
                                    }
                                }
                            } else {
                                self.performSegue(withIdentifier: "LogInSuccess", sender: self)
                                self.activityIndicator.stopAnimating()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Swift.Error!) {
        self.activityIndicator.stopAnimating()
    }
}




