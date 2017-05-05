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
    
    // Properties
    var slot: Slot
    var topic: Topic
    
    required init(slot: Slot, topic: Topic) {
        self.slot = slot
        self.topic = topic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // WebView
        webView!.backgroundColor = MDCPalette.blueGrey().tint800
        webView!.scrollView.backgroundColor = webView!.backgroundColor
        webView!.isUserInteractionEnabled = false
        webView!.navigationDelegate = self
        
        // Spinner
        view.addSubview(spinner)
        spinner.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        spinner.startAnimating()
        
        // Load the beacon page
        if let url = beaconURL() {
            loadURL(url)
        }
    }
    
    // MARK: Internal
    
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
