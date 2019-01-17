//
//  User.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-17.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let displayName: String
    let profileImage: String?
    
    init(uid: String, displayName: String, profileImage: String? = nil) {
        self.uid = uid
        self.displayName = displayName
        self.profileImage = profileImage
    }
    
    init?(dictionary: [String : Any]) {
        guard
            let uid = dictionary[FirestoreKeys.uid.rawValue] as? String,
            let displayName = dictionary[FirestoreKeys.displayName.rawValue] as? String
            else { return nil }
        self.uid = uid
        self.displayName = displayName
        self.profileImage = dictionary[FirestoreKeys.profileImage.rawValue] as? String
    }
    
    var dictionary: [String : Any] {
        var dict: [String : Any] = [ : ]
        dict[FirestoreKeys.uid.rawValue] = uid
        dict[FirestoreKeys.displayName.rawValue] = displayName
        dict[FirestoreKeys.profileImage.rawValue] = profileImage
        return dict
    }
    
    enum FirestoreKeys: String {
        case uid = "uid"
        case displayName = "displayName"
        case profileImage = "profileImage"
    }
}
