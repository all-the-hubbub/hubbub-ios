//
//  HomeHeaderView.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 4/28/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import AlamofireImage
import MaterialComponents
import SnapKit
import UIKit

class HomeHeaderView: UIView {

    let profileImageView: UIImageView = UIImageView()
    let nameLabel: UILabel = UILabel()
    let handleLabel: UILabel = UILabel()

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
        backgroundColor = ColorPrimary

        addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.width.equalTo(56)
            make.height.equalTo(56)
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-20)
        }

        nameLabel.font = UIFont.systemFont(ofSize: 24)
        nameLabel.textColor = .white
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(profileImageView.snp.top)
        }

        handleLabel.font = UIFont.systemFont(ofSize: 14)
        handleLabel.textColor = .white
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

    override class var layerClass: AnyClass {
        return MDCShadowLayer.self
    }

    var shadowLayer: MDCShadowLayer {
        return layer as! MDCShadowLayer
    }

    func setElevation(points: CGFloat) {
        shadowLayer.elevation = points
    }
}
