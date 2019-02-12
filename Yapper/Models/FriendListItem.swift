//
//  FriendListItem.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-29.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation

//
//  User.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-17.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation
import Firebase

struct FriendListItem {
    let uid: String
    let isFriend: Bool
    let isIgnored: Bool
    
    // MARK: - Constructors
    
    init(uid: String, isFriend: Bool, isIgnored: Bool) {
        self.uid = uid
        self.isFriend = isFriend
        self.isIgnored = isIgnored
    }
    
    init?(from dictionary: [String : Any]) {
        guard
            let uid = dictionary[FirestoreKeys.uid.rawValue] as? String
            else {
                Log.e("FriendListItem", "Failed to parse FriendListItem from dictionary")
                return nil }
        let isFriend = dictionary[FirestoreKeys.isFriend.rawValue] as? Bool ?? false
        let isIgnored = dictionary[FirestoreKeys.isIgnored.rawValue] as? Bool ?? false
        self.init(uid: uid, isFriend: isFriend, isIgnored: isIgnored)
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
            FirestoreKeys.isFriend.rawValue : isFriend,
            FirestoreKeys.isIgnored.rawValue : isIgnored
        ]
    }
    
    enum FirestoreKeys: String {
        case uid = "uid"
        case isFriend = "isFriend"
        case isIgnored = "isIgnored"
    }
}
