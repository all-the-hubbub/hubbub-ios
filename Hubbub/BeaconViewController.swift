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

class BeaconViewController: UIViewController {

    // UI
    let appBar = MDCAppBar()
    
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
        appBar.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white
        ]
        if let navShadowLayer = appBar.headerViewController.headerView.shadowLayer as? MDCShadowLayer {
            navShadowLayer.elevation = 3
        }
        navigationItem.title = "Find your group"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "ic_close_white"),
            style: .done,
            target: self,
            action: #selector(back)
        )
        
        // WebView
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(appBar.headerViewController.headerView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        // Load the beacon page
        if let url = URL(string: "https://hubbub-159904.firebaseapp.com/beacon/\(slot.id)/\(topic.id)") {
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
}
