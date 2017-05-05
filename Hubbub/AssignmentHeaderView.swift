//
//  AssignmentHeaderView.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/4/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import MaterialComponents.MaterialPalettes
import SnapKit
import UIKit

class AssignmentHeaderView: UIView {
    
    // UI
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    
    // Properties
    var slot: Slot? {
        didSet {
            titleLabel.text = slot?.name
            
            var desc = ""
            if let startDate = slot?.startDate {
                desc = startFormatter.string(from: startDate)
                if let endDate = slot?.endDate {
                    desc += " - " + endFormatter.string(from: endDate)
                }
            }
            descriptionLabel.text = desc
        }
    }
    
    // Internal
    internal lazy var startFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d\nh:mm a"
        return f
    }()
    internal lazy var endFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = MDCPalette.blueGrey().tint800
        
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.textColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(25)
            make.top.equalToSuperview()
        }
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = titleLabel.textColor
        descriptionLabel.numberOfLines = 2
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
