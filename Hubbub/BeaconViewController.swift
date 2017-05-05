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

class BeaconViewController: UIViewController, WKNavigationDelegate {

    // UI
    let appBar = MDCAppBar()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    // Properties
    var slot: Slot
    var topic: Topic
    
    required init(slot: Slot, topic: Topic) {
        self.slot = slot
        self.topic = topic
        
        super.init(nibName: nil, bundle: nil)
        
        addChildViewController(appBar.headerViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // AppBar
        appBar.addSubviewsToParent()
        appBar.headerViewController.headerView.backgroundColor = MDCPalette.blueGrey().tint800
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "ic_close_white"),
            style: .done,
            target: self,
            action: #selector(back)
        )
        
        // WebView
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.backgroundColor = MDCPalette.blueGrey().tint800
        webView.scrollView.backgroundColor = webView.backgroundColor
        webView.isUserInteractionEnabled = false
        webView.navigationDelegate = self
        view.insertSubview(webView, at: 0)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // Spinner
        view.addSubview(spinner)
        spinner.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        spinner.startAnimating()
        
        // Load the beacon page
        if let url = beaconURL() {
            webView.load(URLRequest(url: url))
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Internal
    
    internal func back() {
        dismiss(animated: true, completion: nil)
    }
    
    internal func beaconURL() -> URL? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "hubbub-159904.firebaseapp.com"
        urlComponents.path = "/assets/beacon.html"
        urlComponents.queryItems = [
            URLQueryItem(name: "slotId", value: slot.id),
            URLQueryItem(name: "topicId", value: topic.id),
            URLQueryItem(name: "topicName", value: topic.name)
        ]
        return urlComponents.url
    }
    
    // MARK: WKWebViewNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }
}
