//
//  WebViewController.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/5/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import MaterialComponents
import MaterialComponents.MaterialPalettes
import SnapKit
import UIKit
import WebKit

class WebViewController: UIViewController {

    // UI
    let appBar = MDCAppBar()
    var webView: WKWebView?

    // Properties
    var initialURL: URL?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addChildViewController(appBar.headerViewController)
    }

    convenience init(initialURL: URL?) {
        self.init(nibName: nil, bundle: nil)
        self.initialURL = initialURL
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // AppBar
        appBar.addSubviewsToParent()
        appBar.headerViewController.headerView.backgroundColor = MDCPalette.blueGrey().tint800
        appBar.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
        ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "ic_close_white"),
            style: .done,
            target: self,
            action: #selector(back)
        )

        // WebView
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        view.insertSubview(webView!, at: 0)
        webView!.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(appBar.headerViewController.headerView.snp.bottom)
            make.bottom.equalToSuperview()
        }

        // Load the initial URL if there is one
        if let url = initialURL {
            loadURL(url)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Internal

    internal func back() {
        dismiss(animated: true, completion: nil)
    }

    internal func loadURL(_ url: URL) {
        _ = webView?.load(URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData))
    }
}
