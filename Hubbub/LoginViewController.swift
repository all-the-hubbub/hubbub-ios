//
//  LoginViewController.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 3/30/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import Alamofire
import Crashlytics
import Firebase
import MaterialComponents
import MaterialComponents.MaterialSnackbar
import SnapKit
import UIKit

class LoginViewController: UIViewController, OAuthDelegate {

    // UI
    var loginButton: MDCRaisedButton!

    // Internal Properties
    internal var oauthClient: OAuthClient
    internal var snackbarToken: MDCSnackbarSuspensionToken?

    required init(oauthClient: OAuthClient) {
        self.oauthClient = oauthClient
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        resumeSnackbar()
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
        toggleLoginButton(enabled: true)
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Prevent Snackbar messages from being displayed in the OAuth SafariViewController.
        // Messages will be resumed via viewDidAppear or deinit
        snackbarToken = MDCSnackbarManager.suspendAllMessages()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resumeSnackbar()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Internal
    internal func resumeSnackbar() {
        if let token = snackbarToken {
            MDCSnackbarManager.resumeMessages(with: token)
        }
    }

    internal func toggleLoginButton(enabled: Bool) {
        loginButton.isEnabled = enabled

        loginButton.setTitle("Login with GitHub", for: .normal)
        loginButton.setTitle("Logging in...", for: .disabled)

        loginButton.setBackgroundColor(ColorSecondary, for: .normal)
        loginButton.setBackgroundColor(ColorSecondary, for: .disabled)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitleColor(.black, for: .disabled)
    }

    internal func loginFailed(tag: String, error: Error) {
        print("\(tag) login failed: \(error)")
        MDCSnackbarManager.show(MDCSnackbarMessage(text: "Login failed"))
        toggleLoginButton(enabled: true)
    }

    internal func doLogin() {
        let vc = GitHubViewController(delegate: self)
        present(vc, animated: true, completion: nil)
    }

    internal func firebaseSignIn(accessToken: String) {
        let credential = FIRGitHubAuthProvider.credential(withToken: accessToken)
        FIRAuth.auth()?.signIn(with: credential) { [weak self] user, error in
            if error != nil {
                self?.loginFailed(tag: "Firebase", error: error!)
                return
            }
            FIRDatabase.database().reference(withPath: "accounts/\(user!.uid)").updateChildValues([
                "githubToken": accessToken,
                "profileNeedsUpdate": true,
            ])
        }
    }

    internal func showPrivacyPolicy() {
        if let url = URL(string: "https://\(Config.StaticHost)/privacy") {
            let vc = WebViewController(initialURL: url)
            vc.navigationItem.title = "Privacy Policy"
            present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: OAuthDelegate
    
    func oauthSucceededWithCode(_ code: String) {
        toggleLoginButton(enabled: false)
        dismiss(animated: true, completion: nil)
        
        let params: Parameters = ["code": code]
        let url = "https://\(Config.FunctionsHost)/githubToken"
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate(statusCode: 200 ..< 300)
            .responseJSON { [weak self] response in
                switch response.result {
                case .success:
                    if let json = response.result.value as? [String: Any], let token = json["access_token"] as? String {
                        self?.firebaseSignIn(accessToken: token)
                    }
                case .failure(let error):
                    self?.loginFailed(tag: "OAuth", error: error)
                }
        }
    }
}
