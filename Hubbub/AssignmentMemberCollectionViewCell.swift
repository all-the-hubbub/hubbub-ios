//
//  AssignmentMemberCollectionViewCell.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/4/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import AlamofireImage
import SnapKit
import UIKit

class AssignmentMemberCollectionViewCell: UICollectionViewCell {

    // UI
    let profileImageView: UIImageView = UIImageView()
    let nameLabel: UILabel = UILabel()
    let handleLabel: UILabel = UILabel()

    // Properties
    var profile: Profile? {
        didSet {
            nameLabel.text = profile?.name
            handleLabel.text = profile?.handle
            if let url = profile?.photoURL {
                profileImageView.af_setImage(withURL: url, filter: CircleFilter())
            } else {
                profileImageView.image = nil
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.width.equalTo(36)
            make.height.equalTo(36)
            make.left.equalToSuperview().offset(60)
            make.centerY.equalToSuperview()
        }

        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.alpha = 0.87
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(profileImageView.snp.top)
        }

        handleLabel.font = UIFont.systemFont(ofSize: 14)
        handleLabel.alpha = 0.54
        addSubview(handleLabel)
        handleLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalTo(nameLabel.snp.right)
            make.top.equalTo(nameLabel.snp.bottom)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
