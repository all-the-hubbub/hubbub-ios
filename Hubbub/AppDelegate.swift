//
//  AppDelegate.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 3/28/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import Crashlytics
import Fabric
import Firebase
import UIKit

// Remote Config
private let RemoteConfigRequiredBuildKey = "ios_required_build"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let rootViewController = UINavigationController()

    var user: FIRUser?
    var remoteConfig: FIRRemoteConfig?
    let oauthClient = GitHubOAuthClient()

    lazy var appBuildNumber: Int = {
        var n = Int.max
        if let versionStr = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, let version = Int(versionStr) {
            n = version
        }
        return n
    }()

    lazy var appVersionString: String? = {
        guard let info = Bundle.main.infoDictionary else { return nil }
        if let version = info["CFBundleShortVersionString"] as? String, let build = info["CFBundleVersion"] as? String {
            return "Hubbub \(version) (\(build))"
        }
        return nil
    }()

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize Fabric
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])

        // Initialize Firebase
        let configPath = Bundle.main.path(forResource: Config.FirebasePlistName, ofType: "plist")
        FIRApp.configure(with: FIROptions(contentsOfFile: configPath))
        initDatabase()
        initAuth()
        initRemoteConfig()

        // Storyboard has no entry point, so create a Window ourselves
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window!.backgroundColor = UIColor.white
        window!.rootViewController = rootViewController
        rootViewController.setNavigationBarHidden(true, animated: false)

        // Ready to launch
        window!.makeKeyAndVisible()
        return true
    }

    func application(_: UIApplication, open url: URL, sourceApplication _: String?, annotation _: Any) -> Bool {
        if url.scheme == "hubbub" {
            oauthClient.handleRedirectURL(url)
            return true
        }
        return false
    }

    func applicationDidBecomeActive(_: UIApplication) {
        remoteConfig?.fetch(withExpirationDuration: TimeInterval(60 * 60)) { [unowned self] status, _ in
            guard let config = self.remoteConfig else { return }

            // Apply new remote values
            if status == .success {
                config.activateFetched()
            }

            // Check for forced upgrade
            if let requiredBuild = config[RemoteConfigRequiredBuildKey].numberValue?.intValue {
                if requiredBuild > self.appBuildNumber {
                    print("Requiring upgrade: current=\(self.appBuildNumber) required=\(requiredBuild)")
                    self.showUpgradeDialog()
                }
            }
        }
    }

    func initDatabase() {
        FIRDatabase.setLoggingEnabled(true)
        FIRDatabase.database().persistenceEnabled = true
    }

    func initRemoteConfig() {
        remoteConfig = FIRRemoteConfig.remoteConfig()
        remoteConfig?.setDefaults([
            RemoteConfigRequiredBuildKey: appBuildNumber as NSObject,
        ])
    }

    func initAuth() {
        FIRAuth.auth()?.addStateDidChangeListener({ [unowned self] _, user in
            // If nothing has changed since the last invocation, return early.
            // This prevents ViewController thrashing in scenarios like a new access token being minted.
            if user != nil && user!.uid == self.user?.uid {
                return
            }
            self.user = user

            // If not logged in, show the login screen. Otherwise show the home screen.
            var vc: UIViewController
            if self.user == nil {
                vc = LoginViewController(oauthClient: self.oauthClient)
            } else {
                vc = HomeViewController(user: self.user!, oauthClient: self.oauthClient)
            }
            self.rootViewController.setViewControllers([vc], animated: false)
        })
    }

    func showUpgradeDialog() {
        let alert = UIAlertController(
            title: "Upgrade Required",
            message: "Please download the latest version of Hubbub",
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: "Open App Store", style: .default) { _ in
            if let url = URL(string: "https://itunes.apple.com/app/\(Config.AppStoreID)") {
                UIApplication.shared.open(url)
            }
        }
        alert.addAction(action)

        rootViewController.present(alert, animated: true, completion: nil)
    }
}
