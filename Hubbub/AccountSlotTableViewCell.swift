//
//  AccountSlotTableViewCell.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 4/30/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import UIKit

class AccountSlotTableViewCell: SlotTableViewCell {

    // UI
    let topicPill = TopicPill()
    let pendingLabel: UILabel = {
        let l = UILabel()
        l.text = "pending..."
        l.font = UIFont.italicSystemFont(ofSize: 12)
        l.textColor = .darkGray
        l.sizeToFit()
        return l
    }()

    // Properties
    override var slot: Slot? {
        get {
            return super.slot
        }
        set {
            super.slot = newValue

            if let topic = slot?.topic {
                topicPill.text = topic.name
                topicPill.sizeToFit()
                accessoryView = topicPill
            } else {
                accessoryView = pendingLabel
            }
        }
    }
}
