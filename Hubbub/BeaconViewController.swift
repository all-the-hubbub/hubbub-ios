//
//  BeaconViewController.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/2/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import MaterialComponents
import MaterialComponents.MaterialPalettes
import SnapKit
import UIKit
import WebKit

class BeaconViewController: WebViewController, WKNavigationDelegate {

    // UI
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    required init(slot: Slot, topic: Topic) {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Config.StaticHost
        urlComponents.path = "/assets/beacon.html"
        urlComponents.queryItems = [
            URLQueryItem(name: "slotId", value: slot.id),
            URLQueryItem(name: "topicId", value: topic.id),
            URLQueryItem(name: "topicName", value: topic.name),
        ]

        super.init(initialURL: urlComponents.url)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // WebView
        webView.backgroundColor = MDCPalette.blueGrey().tint800
        webView.scrollView.backgroundColor = webView.backgroundColor
        webView.isUserInteractionEnabled = false
        webView.navigationDelegate = self

        // Spinner
        view.addSubview(spinner)
        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        spinner.startAnimating()
    }

    // MARK: WKWebViewNavigationDelegate

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        spinner.stopAnimating()
    }
}
