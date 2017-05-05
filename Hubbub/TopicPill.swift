//
//  TopicPill.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/4/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import UIKit

class TopicPill: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = #colorLiteral(red: 0, green: 0.5921568627, blue: 0.6549019608, alpha: 1)
        layer.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.9647058824, blue: 0.9764705882, alpha: 1).cgColor
        
        textAlignment = .center
        font = UIFont.boldSystemFont(ofSize: 12)
        
        clipsToBounds = true
        layer.cornerRadius = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSize = super.sizeThatFits(size)
        return CGSize(width: superSize.width + (2 * 10), height: superSize.height + (2 * 4))
    }
    
    override var intrinsicContentSize: CGSize {
        return sizeThatFits(.zero)
    }
}
