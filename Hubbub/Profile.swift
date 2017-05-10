//
//  Profile.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 4/28/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import Firebase
import Foundation

class Profile: NSObject {
    var userID: String
    var name: String?
    var handle: String?
    var photoURL: URL?

    init?(snapshot: FIRDataSnapshot) {
        guard let data = (snapshot.value as? [String: Any]) else { return nil }

        userID = snapshot.key
        name = data["name"] as? String
        handle = data["handle"] as? String
        if let photo = data["photo"] as? String {
            photoURL = URL(string: photo)
        }
    }
}
