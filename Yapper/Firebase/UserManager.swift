//
//  UserManager.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-17.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation
import Firebase

class UserManager {
    private let db: Firestore
    private var users: [String: User] = [:]
    
    init(database: Firestore) {
        self.db = database
    }
    
    /**
     * Get the User associated with the UID, or fetch it from Firestore if it is not cached.
     */
    func getUser(uid: String, completion: @escaping (User?, Error?) -> Void) {
        if let user = users[uid] {
            // User is cached
            completion(user, nil)
        } else {
            // Fetch the user from Firestore, /Users/uid
            db.collection(FirebaseDefaults.CollectionUsers.rawValue).document(uid).getDocument { (document, error) in
                let user = document.toUser()
                if user != nil { self.users[uid] = user }
                completion(user, error)
            }
        }
    }
    
    /**
     * Create a User document in Firestore database
     */
    func createUser(user: User, completion: ((Error?) -> Void)? ) {
        db.collection(FirebaseDefaults.CollectionUsers.rawValue).addDocument(data: user.dictionary, completion: completion)
    }
    
    func updateUser(user: User, completion: ((Error?) -> Void)?) {
        db.collection(FirebaseDefaults.CollectionUsers.rawValue).document(user.uid).updateData(user.dictionary, completion: completion)
    }
}

extension Optional where Wrapped == DocumentSnapshot {
    func toUser() -> User?{
        return self.flatMap({ $0.data().flatMap({ data in
            return User(dictionary: data)
        })})
    }
}
