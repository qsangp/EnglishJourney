//
//  LogInVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 29/05/2021.
//

import UIKit
import QuartzCore
import FBSDKLoginKit
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
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var signInFacebookButton: FBLoginButton!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light

        configureTextField()
        setupLogInSuccessView()
        updateUI()
                
    }
    func updateUI() {
        hideKeyboardWhenTappedAround()
        signInFacebookButton.isHidden = true
        
        emailTextField.layer.cornerRadius = 20
        passwordTextField.layer.cornerRadius = 20
        loginButton.layer.cornerRadius = 20
        
        googleLoginButton.layer.borderWidth = 1.0
        googleLoginButton.layer.borderColor = UIColor.darkGray.cgColor
        googleLoginButton.layer.cornerRadius = 20
        
        cardViewModel = CardViewModel()
        
        GIDSignIn.sharedInstance().presentingViewController = self
        checkAuthentication()
        
    }
    
    func setupLogInSuccessView() {
        
        view.addSubview(loadingWhiteView)
        loadingWhiteView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingWhiteView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingWhiteView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loadingWhiteView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        loadingWhiteView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        loadingWhiteView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        view.addSubview(popUpImage)
        popUpImage.centerXAnchor.constraint(equalTo: loadingWhiteView.centerXAnchor).isActive = true
        popUpImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        popUpImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(popUpMessageLabel)
        popUpMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        popUpMessageLabel.centerXAnchor.constraint(equalTo: loadingWhiteView.centerXAnchor).isActive = true
        popUpMessageLabel.centerYAnchor.constraint(equalTo: loadingWhiteView.centerYAnchor).isActive = true
        popUpMessageLabel.topAnchor.constraint(equalTo: popUpImage.bottomAnchor, constant: 10).isActive = true
        popUpMessageLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
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
    
//MARK: -Google Login
    @IBAction func btnGooglePressed(_ sender: UIButton) {
        sender.preventRepeatedPresses()
        GIDSignIn.sharedInstance().signIn()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.checkGoogleSignIn()
        }
    }
    
    func checkGoogleSignIn() {

        if GIDSignIn.sharedInstance().hasPreviousSignIn() {
            if let user = GIDSignIn.sharedInstance().currentUser {
                if let email = user.profile.email,
                   let username = email.components(separatedBy: CharacterSet(charactersIn: ("@0123456789"))).first,
                   let id = user.userID {
                    print(email)
                    print(id)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    print("Have error -> create new user -> login")
                        let error = self.cardViewModel.errorMessage
                        if error == "The data couldn’t be read because it is missing." {
                            self.cardViewModel.createUser(name: username, surname: username, username: username, email: email, password: id) {
                                    self.loadingWhiteView.isHidden = false
                                    self.popUpImage.isHidden = false
                                    self.popUpMessageLabel.isHidden = false
                                
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        self.cardViewModel.fetchLogIn(username: email, password: id) {
                                            self.performSegue(withIdentifier: "LogInSuccess", sender: self)
                                            self.cardViewModel.errorMessage = ""
                                            self.loadingWhiteView.isHidden = true
                                            self.popUpImage.isHidden = true
                                            self.popUpMessageLabel.isHidden = true
                                            self.loadingWhiteView.isHidden = true
                                        }
                                    }
                                }
                            
                        } else {}
                    }
                    print("No error -> login")
                    cardViewModel.fetchLogIn(username: email, password: id) {
                        self.performSegue(withIdentifier: "LogInSuccess", sender: self)
                        self.loadingWhiteView.isHidden = true
                    }
                }
            }
        }
    }
    
    @IBAction func skipPressed(_ sender: UIButton) {
        checkGoogleSignIn()
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
                self.loadingWhiteView.isHidden = false
                self.popUpImage.isHidden = false
                self.popUpMessageLabel.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.performSegue(withIdentifier: "LogInSuccess", sender: self)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.loadingWhiteView.isHidden = true
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
        } catch {
            Alert.showBasic(title: "Unable To Login", message: "Appologies! something went wrong. Please try again later...", vc: self)
            cardViewModel.errorMessage = ""

        }

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
        
    }
    
//MARK: - Facebook login
    @IBAction func btnFacebookPressed(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.checkFacebookLogin()
            print("done")
        }
    }
    
    func checkFacebookLogin() {
        if let token = AccessToken.current,
                !token.isExpired {
            let token = token.tokenString
            
            let request = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                    parameters: ["fields": "email, name"],
                                                     tokenString: token,
                                                     version: nil,
                                                     httpMethod: .get)
            request.start(completionHandler: {connection, result, error in
                if let userInfo = result as? [String: Any] {
                    let name = userInfo["name"] as! String
                    let email = userInfo["email"] as! String
                    let id = userInfo["id"] as! String
                    print("\(name), \(email), \(id)")
                    
                    self.cardViewModel.fetchLogIn(username: email, password: id) {
                        self.emailTextField.text = email
                        self.passwordTextField.text = id
                        self.loginButton.sendActions(for: .touchUpInside)

                    }
                }
            })
        } else {
            signInFacebookButton.permissions = ["public_profile", "email"]
            
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



