//
//  AssignmentCollectionViewHeader.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/4/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import SnapKit
import UIKit

class AssignmentCollectionViewHeader: UICollectionReusableView {
    
    // UI
    let iconImageView = UIImageView()
    let contentView = UIView()
    let titleLabel = UILabel()
    let topicPill = TopicPill()
    
    // Properties
    var icon: UIImage? {
        didSet {
            iconImageView.image = icon
        }
    }
    var title: String? {
        didSet {
            titleLabel.text = title
            titleLabel.isHidden = (title == nil)
        }
    }
    var topic: Topic? {
        didSet {
            topicPill.text = topic?.name
            topicPill.sizeToFit()
            topicPill.isHidden = (topic == nil)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        iconImageView.tintColor = #colorLiteral(red: 0.4470588235, green: 0.4470588235, blue: 0.4470588235, alpha: 1)
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.width.equalTo(24)
            make.height.equalTo(24)
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.isHidden = true
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.alpha = 0.87
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        topicPill.isHidden = true
        contentView.addSubview(topicPill)
        topicPill.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(20)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
