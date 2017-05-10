//
//  AssignmentCollectionViewHeader.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/4/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import SnapKit
import UIKit

class AssignmentTopicHeaderView: AssignmentCollectionViewHeader {

    // UI
    let topicPill = TopicPill()

    // Properties
    override var icon: UIImage? {
        return #imageLiteral(resourceName: "ic_subject")
    }

    var topic: Topic? {
        didSet {
            topicPill.text = topic?.name
            topicPill.sizeToFit()
            topicPill.isHidden = (topic == nil)
            titleLabel.isHidden = !topicPill.isHidden
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.text = "pending..."
        titleLabel.font = UIFont.italicSystemFont(ofSize: 12)
        titleLabel.textColor = .darkGray

        topicPill.isHidden = true
        contentView.addSubview(topicPill)
        topicPill.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(20)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AssignmentLocationHeaderView: AssignmentCollectionViewHeader {
    override var icon: UIImage? {
        return #imageLiteral(resourceName: "ic_location_on")
    }
}

class AssignmentMembersHeaderView: AssignmentCollectionViewHeader {
    override var icon: UIImage? {
        return #imageLiteral(resourceName: "ic_people")
    }
}

class AssignmentCollectionViewHeader: UICollectionReusableView {

    // UI
    let iconImageView = UIImageView()
    let contentView = UIView()
    let titleLabel = UILabel()

    // Properties
    var icon: UIImage? {
        return nil
    }

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        iconImageView.tintColor = #colorLiteral(red: 0.4470588235, green: 0.4470588235, blue: 0.4470588235, alpha: 1)
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(24)
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)

        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.alpha = 0.87
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AssignmentMembersFooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.alpha = 0.38
        label.text = "You will be assigned a topic and matched with others as the event approaches!"
        label.numberOfLines = 0
        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(66)
            make.right.equalToSuperview().offset(-66)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
