//
//  Slot.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 4/25/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import Firebase
import Foundation

class Slot: NSObject {

    var id: String
    var name: String?
    var location: String?
    var startAt: Int?
    var endAt: Int?
    var topic: Topic?
    var state: String?

    var startDate: Date? {
        if startAt == nil {
            return nil
        }
        return Date(timeIntervalSince1970: TimeInterval(startAt!))
    }

    var endDate: Date? {
        if endAt == nil {
            return nil
        }
        return Date(timeIntervalSince1970: TimeInterval(endAt!))
    }

    init?(key: String, data: [String: Any]) {
        id = key
        name = data["name"] as? String
        location = data["location"] as? String
        startAt = data["startAt"] as? Int
        endAt = data["endAt"] as? Int
        if let topicData = data["topic"] as? [String: Any] {
            topic = Topic(data: topicData)
        }
        state = data["state"] as? String
    }

    convenience init?(snapshot: FIRDataSnapshot) {
        guard let data = snapshot.value as? [String: Any] else { return nil }
        self.init(key: snapshot.key, data: data)
    }
}
