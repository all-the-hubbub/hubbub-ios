//
//  HomeSlotsTableFooterView.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/3/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import UIKit

class HomeSlotsTableFooterView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.alpha = 0.38
        label.text = "Add an event to hangout with people that share your interests!"
        label.numberOfLines = 0
        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { (make) in
            // Decrease priority to respect UITableView settings its own width==0 constraint
            // when the footer isn't being shown, but use ours when that constraint is removed.
            make.left.equalToSuperview().offset(66).priority(750)
            make.right.equalToSuperview().offset(-66).priority(750)
            
            make.top.equalToSuperview().offset(22)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}