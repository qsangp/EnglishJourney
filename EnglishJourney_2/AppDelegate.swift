

// Swift
//
// AppDelegate.swift
import GoogleSignIn
import UIKit
import AuthenticationServices
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                print("user has granted permission!")
            } else {
                print(error?.localizedDescription as Any)
            }
        }
                                        
        do {
            try Network.reachability = Reachability(hostname: "ielts-vuive.com")
        }
        catch {
            switch error as? Network.Error {
            case let .failedToCreateWith(hostname)?:
                print("Network error:\nFailed to create reachability object With host named:", hostname)
            case let .failedToInitializeWith(address)?:
                print("Network error:\nFailed to initialize reachability object With address:", address)
            case .failedToSetCallout?:
                print("Network error:\nFailed to set callout")
            case .failedToSetDispatchQueue?:
                print("Network error:\nFailed to set DispatchQueue")
            case .none:
                print(error)
            }
        }
        
        GIDSignIn.sharedInstance().clientID = "719651675622-em16i7189mq54pmgu4lbtc31nrdhr65r.apps.googleusercontent.com"
        
        // Apple Sign-in
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                print("\(KeychainItem.currentUserIdentifier)")
                break // The Apple ID credential is valid.
            case .revoked, .notFound:
                // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                print("The Apple ID credential is either revoked or was not found")
            default:
                break
            }
        }

        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        return GIDSignIn.sharedInstance().handle(url)
        
    }
    
}

