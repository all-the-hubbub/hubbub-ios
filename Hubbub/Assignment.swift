//
//  Assignment.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/4/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import Firebase
import Foundation

class Assignment: NSObject {
    var topicID: String
    var topicName: String?
    var members: [String]

    init?(snapshot: FIRDataSnapshot) {
        guard let data = (snapshot.value as? [String: Any]) else { return nil }

        topicID = snapshot.key
        topicName = data["name"] as? String
        members = [String]()

        if let members = data["members"] as? [String: Bool] {
            for (uid, _) in members {
                self.members.append(uid)
            }
        }
    }
}
