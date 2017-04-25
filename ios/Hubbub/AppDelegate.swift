//
//  AppDelegate.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 3/28/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import Firebase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let oauthClient = GitHubOAuthClient()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let rootViewController = UINavigationController()
        
        // Initialize Firebase
        FIRApp.configure()
        FIRDatabase.setLoggingEnabled(true)
        
        // Handle auth state changes:
        // If not logged in, show the login screen. Otherwise show the home screen.
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            var vc:UIViewController
            if (user == nil) {
                vc = LoginViewController(oauthClient: self.oauthClient)
            } else {
                vc = HomeViewController(user: user!, oauthClient: self.oauthClient)
            }
            rootViewController.setViewControllers([vc], animated: false)
        })
        
        // Storyboard has no entry point, so create a Window ourselves
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window!.backgroundColor = UIColor.white
        window!.rootViewController = rootViewController
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
}
