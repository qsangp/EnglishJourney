//
//  LogInVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 29/05/2021.
//

import UIKit
import QuartzCore
import GoogleSignIn
import AuthenticationServices

class LogInVC: UIViewController {
    
    let mainTitle: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "English Journey"
        title.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        title.textAlignment = .center
        title.sizeToFit()
        title.numberOfLines = 0
        title.minimumScaleFactor = 0.5
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.setLeftPaddingPoints(15)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .white
        tf.layer.masksToBounds = true
        tf.layer.cornerRadius = 5
        tf.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.setLeftPaddingPoints(15)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        tf.textContentType = .password
        tf.backgroundColor = .white
        tf.layer.masksToBounds = true
        tf.layer.cornerRadius = 5
        tf.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        return tf
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.00, green: 0.73, blue: 0.75, alpha: 1.00)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor(red: 0.00, green: 0.64, blue: 0.64, alpha: 1.00).cgColor
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(logInButtonPressed), for: .touchUpInside)
        return button
    }()
    
    var viewModel: CardViewModel!
    let service = Service()
    let progressHUD = ProgressHUD(text: "Loading...")
    
    private let appleSignInButton = ASAuthorizationAppleIDButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        updateUI()
    }
    
    func updateUI() {
        hideKeyboardWhenTappedAround()
        overrideUserInterfaceStyle = .light
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.overrideUserInterfaceStyle = .light
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationItem.title = "Sign in"

        let height = view.frame.width/8
        view.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.00)
        
        view.addSubview(mainTitle)
        mainTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height/3).isActive = true
        mainTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        mainTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        mainTitle.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true

        view.addSubview(emailTextField)
        emailTextField.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: 20).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        emailTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
        
        view.addSubview(passwordTextField)
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        passwordTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
        
        view.addSubview(loginButton)
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        loginButton.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
    
        self.view.addSubview(progressHUD)
        progressHUD.isHidden = true
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
    
    @objc func logInButtonPressed(_ sender: UIButton) {
        sender.preventRepeatedPresses()
        
        do {
            try login()
            let email = emailTextField.text!
            let password = passwordTextField.text!
            
            service.fetchLogin(email: email, password: password) { [weak self] results in
                switch results {
                case .success(_):
                    self?.clearTextField()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PeformAfterPresenting"), object: nil)
                    self?.dismiss(animated: true)
                    self?.progressHUD.isHidden = true
                case .failure(_):
                    self?.viewModel.needShowError = { [weak self] error in
                        self?.showError(error: error)
                        self?.progressHUD.isHidden = true
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

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

//MARK: - Social login
class SocialLoginVC: UIViewController {
        
    static let identifier = "SocialLoginVC"
    let progressHUD = ProgressHUD(text: "Loading...")
    let service = Service()
    var viewModel: CardViewModel!
        
    let mainTitle: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Start your English Journey"
        title.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        title.textAlignment = .center
        title.sizeToFit()
        title.numberOfLines = 0
        title.minimumScaleFactor = 0.5
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    private let googleButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign in with Google", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        return button
    }()
    
    private let appleSignInButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign in with Apple ", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        return button
    }()
    
    private let alreadyHasAccountButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Already Has Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.00, green: 0.73, blue: 0.75, alpha: 1.00)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor(red: 0.00, green: 0.64, blue: 0.64, alpha: 1.00).cgColor
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(loginVCPressed), for: .touchUpInside)
        return button
    }()
    
    @objc func signInWithGoogle(_ sender: UIButton!) {
        sender.preventRepeatedPresses()
        GIDSignIn.sharedInstance().signIn()
    }
    
    @objc func signInWithApple(_ sender: ASAuthorizationAppleIDButton!) {
    }
    
    @objc func loginVCPressed() {
        self.performSegue(withIdentifier: "GoToLoginVC", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        
        updateUI()
    }
    
    private func updateUI() {
        overrideUserInterfaceStyle = .light
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.overrideUserInterfaceStyle = .light
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationItem.title = "Social Sign in"

        let height = view.frame.width/8
        view.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.00)
        
        view.addSubview(mainTitle)
        mainTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height/3).isActive = true
        mainTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        mainTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        mainTitle.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true

        view.addSubview(googleButton)
        googleButton.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: 20).isActive = true
        googleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        googleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        googleButton.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
        
        let googleLogo = UIImageView.init(image: UIImage(named: "google"))
        googleLogo.translatesAutoresizingMaskIntoConstraints = false
        googleButton.addSubview(googleLogo)
        googleLogo.centerYAnchor.constraint(equalTo: googleButton.centerYAnchor).isActive = true
        googleLogo.leadingAnchor.constraint(equalTo: googleButton.leadingAnchor, constant: 10).isActive = true
        googleLogo.widthAnchor.constraint(equalToConstant: height/2).isActive = true
        googleLogo.heightAnchor.constraint(equalToConstant: height/2).isActive = true
 
        
        view.addSubview(appleSignInButton)
        appleSignInButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        appleSignInButton.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 10).isActive = true
        appleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        appleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        appleSignInButton.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
        
        let appleLogo = UIImageView.init(image: UIImage(named: "apple"))
        appleLogo.translatesAutoresizingMaskIntoConstraints = false
        appleSignInButton.addSubview(appleLogo)
        appleLogo.centerYAnchor.constraint(equalTo: appleSignInButton.centerYAnchor).isActive = true
        appleLogo.leadingAnchor.constraint(equalTo: appleSignInButton.leadingAnchor, constant: 10).isActive = true
        appleLogo.widthAnchor.constraint(equalToConstant: height/2).isActive = true
        appleLogo.heightAnchor.constraint(equalToConstant: height/2).isActive = true
        
        view.addSubview(alreadyHasAccountButton)
        alreadyHasAccountButton.topAnchor.constraint(equalTo: appleSignInButton.bottomAnchor, constant: 10).isActive = true
        alreadyHasAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        alreadyHasAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        alreadyHasAccountButton.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
        
        self.view.addSubview(progressHUD)
        progressHUD.isHidden = true
    }
    
//MARK: - Apple Login
    // - Tag: perform_appleid_password_request
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func createNewUser(name: String, email: String) {
        service.createUser(name: name, email: email) { [weak self] errorMessage in
            if errorMessage == nil {
                self?.fetchLogin(email: email)
            } else {
                print(errorMessage!)
                self?.fetchLogin(email: email)
            }
        }
    }
    
    func fetchLogin(email: String) {
        service.fetchLogin(email: email, password: "s@ng7nQ-ij") { [weak self] results in
            switch results {
            case .success(_):
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PeformAfterPresenting"), object: nil)
                    self?.dismiss(animated: true)
                    self?.progressHUD.isHidden = true
                }
            case .failure(let error):
                print("login failed: \(error.localizedDescription)")
                self?.viewModel.needShowError = { [weak self] error in
                    self?.showError(error: error)
                    self?.progressHUD.isHidden = true
                }
            }
        }
    }
    
    private func showError(error: ErrorMessage) {
        let alert = UIAlertController(title: "Error", message: error.rawValue, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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

extension HomeViewController {
    
    func showLoginVCFromHomeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "loginNavigationController") as? UINavigationController {
            vc.modalPresentationStyle = .fullScreen
            vc.isModalInPresentation = true
            let loginViewController = vc.topViewController as? SocialLoginVC
            loginViewController?.viewModel = viewModel
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    
    func showLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "loginNavigationController") as? UINavigationController {
            vc.modalPresentationStyle = .fullScreen
            vc.isModalInPresentation = true
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension SocialLoginVC: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            self.saveUserInKeychain(userIdentifier)
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.example.apple-samplecode.juice", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
        let userId = userIdentifier.prefix(8)
        let newEmail = "\(userId)@privaterelay.appleid"
        self.createNewUser(name: String(userId), email: newEmail)
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// - Tag: did_complete_error
    private func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("something happened \(error)")
    }
}

extension SocialLoginVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension SocialLoginVC: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Swift.Error!) {
        progressHUD.isHidden = false
        
        if error != nil {
            print(error.localizedDescription)
            progressHUD.isHidden = true

        } else {
            if GIDSignIn.sharedInstance().hasPreviousSignIn() {
                if let user = GIDSignIn.sharedInstance().currentUser {
                    if let email = user.profile.email,
                       let shortenedEmail = email.components(separatedBy: CharacterSet(charactersIn: ("@0123456789"))).first {
                        if user.profile.hasImage,
                           let name = user.profile.name,
                           let familyName = user.profile.familyName,
                           let userImageURL = user.profile.imageURL(withDimension: 500) {
                            UserDefaults.standard.set(userImageURL, forKey: "userImageURL")
                        }
                        createNewUser(name: shortenedEmail, email: email)
                    }
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Swift.Error!) {
        if let error = error {
            print(error.localizedDescription)
            progressHUD.isHidden = true
        }
    }
}






