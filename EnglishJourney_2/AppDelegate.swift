

// Swift
//
// AppDelegate.swift
import GoogleSignIn
import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        GIDSignIn.sharedInstance().clientID = "719651675622-em16i7189mq54pmgu4lbtc31nrdhr65r.apps.googleusercontent.com"

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
    
