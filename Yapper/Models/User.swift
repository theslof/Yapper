//
//  User.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-17.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let uid: String
    var displayName: String
    var profileImage: String
    
    // MARK: - Constructors
    
    init(uid: String, displayName: String, profileImage: String = "") {
        self.uid = uid
        self.displayName = displayName
        self.profileImage = profileImage
    }
    
    init?(from dictionary: [String : Any]) {
        guard
            let uid = dictionary[FirestoreKeys.uid.rawValue] as? String,
            let displayName = dictionary[FirestoreKeys.displayName.rawValue] as? String
            else { return nil }
        let profileImage = dictionary[FirestoreKeys.profileImage.rawValue] as? String ?? ""
        self.init(uid: uid, displayName: displayName, profileImage: profileImage)
    }
    
    init?(from doc: DocumentSnapshot?){
        guard
            let data: [String : Any] = doc?.data()
            else { return nil }
        self.init(from: data)
    }
    
    // MARK: - Utilities
    
    func toDictionary() -> [String : Any] {
        return [
            FirestoreKeys.uid.rawValue : uid,
            FirestoreKeys.displayName.rawValue : displayName,
            FirestoreKeys.profileImage.rawValue : profileImage
        ]
    }
    
    enum FirestoreKeys: String {
        case uid = "uid"
        case displayName = "displayName"
        case profileImage = "profileImage"
    }
}
