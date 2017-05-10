//
//  TopicPill.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/4/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import MaterialComponents.MaterialPalettes
import UIKit

class TopicPill: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = MDCPalette.cyan().tint800
        layer.backgroundColor = MDCPalette.cyan().accent700?.withAlphaComponent(0.12).cgColor

        textAlignment = .center
        font = UIFont.boldSystemFont(ofSize: 12)

        clipsToBounds = true
        layer.cornerRadius = 3
    }

    required init?(coder _: NSCoder) {
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
