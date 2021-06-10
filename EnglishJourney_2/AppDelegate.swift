

// Swift
//
// AppDelegate.swift
import GoogleSignIn
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        setupNotification(on: application)
        
        do {
            try Network.reachability = Reachability(hostname: "www.google.com")
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

extension AppDelegate {
    func setupNotification(on application: UIApplication) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Failed to  request Authorization for notification center: \(error.localizedDescription)")
                return
            }
            guard granted else {
                print("Failed to  request Authorization for notification center: not granted")
                return
            }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}

