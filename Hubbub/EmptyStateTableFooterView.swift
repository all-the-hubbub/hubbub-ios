//
//  HomeSlotsTableFooterView.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/3/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import UIKit

class EmptyStateTableFooterView: UIView {
    
    // UI
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let msgLabel = UILabel()
    
    // Properties
    var loading: Bool = false {
        didSet {
            if loading {
                spinner.startAnimating()
                msgLabel.isHidden = true
            } else {
                spinner.stopAnimating()
                msgLabel.isHidden = false
            }
        }
    }
    var message: String? {
        didSet {
            msgLabel.text = message
        }
    }
    
    required init(insets: UIEdgeInsets) {
        super.init(frame: .zero)
        
        addSubview(spinner)
        spinner.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(insets.top)
        }
        
        msgLabel.font = UIFont.systemFont(ofSize: 14)
        msgLabel.textColor = .black
        msgLabel.alpha = 0.38
        msgLabel.numberOfLines = 0
        msgLabel.textAlignment = .center
        addSubview(msgLabel)
        msgLabel.snp.makeConstraints { (make) in
            // Decrease priority to respect UITableView settings its own width==0 constraint
            // when the footer isn't being shown, but use ours when that constraint is removed.
            make.left.equalToSuperview().offset(insets.left).priority(750)
            make.right.equalToSuperview().offset(-insets.right).priority(750)
            
            make.top.equalToSuperview().offset(insets.top)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
