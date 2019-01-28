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
    private static let TAG: String = "UserManager"
    private let db: Firestore
    private var users: [String: User] = [:]
    private var userListener: ListenerRegistration?
    private var callbacks: [([User]?, Error?) -> Void] = []
    
    init(database: Firestore) {
        self.db = database
        userListener = db.collection(FirebaseDefaults.CollectionUsers.rawValue)
            .addSnapshotListener { (snapshot, error) in
                if let documents = snapshot?.documents {
                    documents.compactMap(User.init(from:)).forEach({ user in
                        self.users[user.uid] = user
                    })
                    for callback in self.callbacks {
                        let users = Array(self.users.values)
                        callback(users, nil)
                    }
                } else if let error = error {
                    Log.e(UserManager.TAG, error.localizedDescription)
                    for callback in self.callbacks {
                        callback(nil, error)
                    }
                }
                self.callbacks.removeAll()
        }
    }
    
    /**
     * Get the User associated with the UID, or fetch it from Firestore if it is not cached.
     */
    func getUser(uid: String, completion: @escaping (User?, Error?) -> Void) {
        Log.d(UserManager.TAG, "Fetching user \(uid)...")
        if let user = users[uid] {
            // User is cached
            Log.d(UserManager.TAG, "User was cached")
            completion(user, nil)
        } else {
            // Fetch the user from Firestore, /Users/uid
            db.collection(FirebaseDefaults.CollectionUsers.rawValue).document(uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    Log.d(UserManager.TAG, "Fetched user from Firestore")
                    let user = User(from: document)
                    if user != nil { self.users[uid] = user }
                    else { Log.d(UserManager.TAG, "Unable to parse user") }
                } else {
                    Log.d(UserManager.TAG, "User does not exist")
                }
                completion(self.users[uid], error)
            }
        }
    }
    
    func getUsers(completion: @escaping ([User]?, Error?) -> Void) {
        if users.isEmpty {
            Log.d(UserManager.TAG, "Loading users, adding callback")
            self.callbacks.append(completion)
        } else {
            Log.d(UserManager.TAG, "Users were already loaded, executing callback")
            completion(Array(users.values), nil)
        }
    }
    
//    func getUsers() -> [User] {
//        return Array(users.values)
//    }
    
    /**
     * Create a User document in Firestore database
     */
    func createUser(user: User, completion: ((Error?) -> Void)? ) {
        db.collection(FirebaseDefaults.CollectionUsers.rawValue).document(user.uid).setData(user.toDictionary(), completion: completion)
    }
    
    func updateUser(user: User, completion: ((Error?) -> Void)?) {
        db.collection(FirebaseDefaults.CollectionUsers.rawValue).document(user.uid).updateData(user.toDictionary(), completion: completion)
    }
}
