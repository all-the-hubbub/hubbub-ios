//
//  LoginViewController.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 3/30/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import Firebase
import MaterialComponents
import SnapKit
import UIKit
import Crashlytics

class LoginViewController: UIViewController {

    // UI
    var loginButton: MDCRaisedButton!

    // Internal Properties
    internal var oauthClient: OAuthClient

    required init(oauthClient: OAuthClient) {
        self.oauthClient = oauthClient
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPrimary

        let container = UIView()
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }

        // Hero Icon
        let hero = UIImageView(image: #imageLiteral(resourceName: "hubbub-hero"))
        container.addSubview(hero)
        hero.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }

        // Title
        let title = UILabel()
        title.text = "Hubbub"
        title.textAlignment = .center
        title.textColor = .white
        title.font = UIFont.systemFont(ofSize: 32)
        container.addSubview(title)
        title.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(hero.snp.bottom).offset(10)
        }

        // Tagline
        let tagline = UILabel()
        tagline.text = "Meet people with similar interests"
        tagline.textAlignment = .center
        tagline.textColor = .white
        tagline.alpha = 0.54
        tagline.font = UIFont.systemFont(ofSize: 16)
        container.addSubview(tagline)
        tagline.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(title.snp.bottom).offset(5)
        }

        // Login
        loginButton = MDCRaisedButton()
        loginButton.setElevation(2, for: .normal)
        loginButton.setTitle("Login with GitHub", for: .normal)
        loginButton.setTitle("Logging in...", for: .disabled)
        loginButton.setBackgroundColor(ColorSecondary, for: .normal)
        loginButton.setBackgroundColor(ColorSecondary, for: .disabled)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitleColor(.white, for: .disabled)
        loginButton.addTarget(self, action: #selector(doLogin), for: UIControlEvents.touchUpInside)
        container.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(tagline.snp.bottom).offset(40)
            make.bottom.equalToSuperview()
        }

        // Privacy Policy
        let privacyPolicy = UIButton(type: .system)
        privacyPolicy.setTitle("Privacy Policy", for: .normal)
        privacyPolicy.setTitleColor(.white, for: .normal)
        privacyPolicy.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        privacyPolicy.alpha = 0.5
        privacyPolicy.addTarget(self, action: #selector(showPrivacyPolicy), for: .touchUpInside)
        view.addSubview(privacyPolicy)
        privacyPolicy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Internal

    internal func doLogin() {
        oauthClient.authorize(from: self, callback: { [unowned self] accessToken, error in
            if error != nil {
                print("OAuth was cancelled or failed: \(error)")
                return
            }
            print("OAuth successful: access_token=\(accessToken!)")

            // Fabric event tracking
            Answers.logLogin(withMethod: "Github", success: true, customAttributes: nil)

            self.loginButton.isEnabled = false
            self.firebaseSignIn(accessToken: accessToken!)
        })
    }

    internal func firebaseSignIn(accessToken: String) {
        let credential = FIRGitHubAuthProvider.credential(withToken: accessToken)
        FIRAuth.auth()?.signIn(with: credential) { user, error in
            if error != nil {
                print("Firebase Auth error: \(error)")
                return
            }
            FIRDatabase.database().reference(withPath: "accounts/\(user!.uid)/githubToken").setValue(accessToken)
        }
    }

    internal func showPrivacyPolicy() {
        if let url = URL(string: "https://\(Config.StaticHost)/privacy") {
            let vc = WebViewController(initialURL: url)
            vc.navigationItem.title = "Privacy Policy"
            present(vc, animated: true, completion: nil)
        }
    }
}
