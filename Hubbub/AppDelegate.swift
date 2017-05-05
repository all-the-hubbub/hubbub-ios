//
//  AppDelegate.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 3/28/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import Firebase
import UIKit
import Fabric
import Crashlytics


// Remote Config
private let RemoteConfigRequiredBuildKey = "ios_required_build"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var user: FIRUser?
    let oauthClient = GitHubOAuthClient()
    let rootViewController = UINavigationController()
    
    lazy var appVersionString: String? = {
        guard let info = Bundle.main.infoDictionary else { return nil }
        if let version = info["CFBundleShortVersionString"] as? String, let build = info["CFBundleVersion"] as? String {
            return "Hubbub \(version) (\(build))"
        }
        return nil
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize Fabric
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])

        // Initialize Firebase
        FIRApp.configure()
        FIRDatabase.setLoggingEnabled(true)
        initRemoteConfig()

        // Firebase Auth
        FIRAuth.auth()?.addStateDidChangeListener({ [unowned self] (auth, user) in
            // If nothing has changed since the last invocation, return early.
            // This prevents ViewController thrashing in scenarios like a new access token being minted.
            if (user != nil && user!.uid == self.user?.uid) {
                return
            }
            self.user = user
        
            // If not logged in, show the login screen. Otherwise show the home screen.
            var vc:UIViewController
            if (self.user == nil) {
                vc = LoginViewController(oauthClient: self.oauthClient)
            } else {
                vc = HomeViewController(user: self.user!, oauthClient: self.oauthClient)
            }
            self.rootViewController.setViewControllers([vc], animated: false)
        })

        // Storyboard has no entry point, so create a Window ourselves
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window!.backgroundColor = UIColor.white
        window!.rootViewController = rootViewController
        rootViewController.setNavigationBarHidden(true, animated: false)
        
        // Ready to launch
        window!.makeKeyAndVisible()
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.scheme == "hubbub" {
            self.oauthClient.handleRedirectURL(url)
            return true
        }
        return false
    }
    
    func initRemoteConfig() {
        let config = FIRRemoteConfig.remoteConfig()
        var defaults = [String : NSObject]()
        
        // Required build version:
        // By setting currentBuild to Int.max we avoid always showing an upgrade dialog if unable to parse the build number
        var currentBuild = Int.max
        if let versionStr = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, let version = Int(versionStr) {
            currentBuild = version
        }
        defaults[RemoteConfigRequiredBuildKey] = currentBuild as NSObject
        
        // Apply defaults and fetch new values
        config.setDefaults(defaults)
        config.fetch(withExpirationDuration: TimeInterval(60*60)) { [unowned self] (status, err) in
            // Apply new remote values
            if status == .success {
                config.activateFetched()
            }
            
            // Check for forced upgrade
            if let requiredBuild = config[RemoteConfigRequiredBuildKey].numberValue?.intValue {
                if requiredBuild > currentBuild {
                    print("Requiring upgrade: current=\(currentBuild) required=\(requiredBuild)")
                    self.showUpgradeDialog()
                }
            }
        }
    }
    
    func showUpgradeDialog() {
        let alert = UIAlertController(
            title: "Upgrade Required",
            message: "Please download the latest version of Hubbub from the App Store",
            preferredStyle: .alert
        )
        rootViewController.present(alert, animated: true, completion: nil)
    }
}
