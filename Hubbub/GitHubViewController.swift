//
//  GitHubViewController.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/16/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import UIKit
import WebKit

protocol OAuthDelegate: class {
    func oauthSucceededWithCode(_ code: String)
}

class GitHubViewController: WebViewController, WKNavigationDelegate {

    // Properties
    weak var delegate: OAuthDelegate?

    required init(delegate: OAuthDelegate? = nil) {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "github.com"
        urlComponents.path = "/login/oauth/authorize"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Config.GitHubOAuthClientID),
            URLQueryItem(name: "redirect_uri", value: "https://\(Config.StaticHost)/oauth"),
        ]

        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()

        super.init(initialURL: urlComponents.url, config: config)
        
        self.delegate = delegate
        webView.navigationDelegate = self
        navigationItem.title = "GitHub Login"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: WKNavigationDelegate

    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy = .allow

        // Intercept success redirect that contains the oauth code. Extract the code and pass it to the delegate.
        if let url = navigationAction.request.url {
            if url.host == Config.StaticHost {
                if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    for item in urlComponents.queryItems ?? [] {
                        if item.name == "code" && item.value != nil {
                            delegate?.oauthSucceededWithCode(item.value!)
                            action = .cancel
                            break
                        }
                    }
                }
            }
        }

        decisionHandler(action)
    }
}
