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
    private var friendList: [String : FriendListItem] = [:]
    private var userListener: ListenerRegistration?
    private var friendListener: ListenerRegistration?
    private var callbacks: [([User]?, Error?) -> Void] = []
    
    init(database: Firestore) {
        self.db = database
        userListener = db.collection(FirebaseDefaults.CollectionUsers.rawValue)
            .addSnapshotListener { (snapshot, error) in
                if let documents = snapshot?.documents {
                    documents.compactMap(User.init(from:)).forEach({ user in
                        self.users[user.uid] = user
                    })
                    Log.d(UserManager.TAG, "Data fetched, executing \(self.callbacks.count) callbacks")
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
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        friendListener = db.collection(FirebaseDefaults.CollectionUsers.rawValue).document(uid)
            .collection(FirebaseDefaults.CollectionFriendsList.rawValue)
            .addSnapshotListener { (snapshot, error) in
                if let documents = snapshot?.documents {
                    documents.compactMap(FriendListItem.init(from:)).forEach({ item in
                        self.friendList[item.uid] = item
                    })
                } else if let error = error {
                    Log.e(UserManager.TAG, error.localizedDescription)
                }
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
    
    /**
     * Get a list of all Users, or add the completion callback to the queue that is processed as soon as they are fetched from Firestore
     */
    func getUsers(completion: @escaping ([User]?, Error?) -> Void) {
        if users.isEmpty {
            Log.d(UserManager.TAG, "Loading users, adding callback")
            self.callbacks.append(completion)
        } else {
            Log.d(UserManager.TAG, "Users were already loaded, executing callback")
            completion(Array(users.values), nil)
        }
    }
    
    func getUsersFor(_ uids: [String], completion: @escaping ([User]?, Error?) -> Void) {
        if users.isEmpty {
            Log.d(UserManager.TAG, "Loading users, adding callback")
            self.callbacks.append {users, error in
                if let users = users {
                    completion(
                        users.filter({ user -> Bool in uids.contains(user.uid) }),
                        error)
                } else {
                    completion(users, error)
                }
            }
        } else {
            Log.d(UserManager.TAG, "Users were already loaded, executing callback")
            completion(
                Array(users.filter({ (uid, user) -> Bool in uids.contains(uid) }).values), nil)
        }
    }
    
    /**
     * Create a User document in Firestore database
     */
    func createUser(user: User, completion: ((Error?) -> Void)? ) {
        db
            .collection(FirebaseDefaults.CollectionUsers.rawValue)
            .document(user.uid).setData(user.toDictionary(), completion: completion)
    }
    
    func updateUser(user: User, completion: ((Error?) -> Void)?) {
        db
            .collection(FirebaseDefaults.CollectionUsers.rawValue)
            .document(user.uid).updateData(user.toDictionary(), completion: completion)
    }
    
    func updateUser(profileImage: User.ProfileImage, for user: String, completion: ((Error?) -> Void)?) {
        db
            .collection(FirebaseDefaults.CollectionUsers.rawValue)
            .document(user).updateData([User.FirestoreKeys.profileImage.rawValue: profileImage.rawValue], completion: completion)
    }
    
    func getFriendlist() -> [String : FriendListItem] {
        return friendList
    }
    
    func setFriendFor(_ user: String, friend: String, isFriend: Bool, completion: ((Error?) -> Void)? = nil) {
        db
            .collection(FirebaseDefaults.CollectionUsers.rawValue)
            .document(user).collection(FirebaseDefaults.CollectionFriendsList.rawValue)
            .document(friend).setData([
                FriendListItem.FirestoreKeys.uid.rawValue : friend,
                FriendListItem.FirestoreKeys.isFriend.rawValue : isFriend],
                                      merge: true, completion: completion)
    }
    
    func setIgnoredFor(_ user: String, friend: String, isIgnored: Bool, completion: ((Error?) -> Void)? = nil) {
        db
            .collection(FirebaseDefaults.CollectionUsers.rawValue)
            .document(user).collection(FirebaseDefaults.CollectionFriendsList.rawValue)
            .document(friend).setData([
                FriendListItem.FirestoreKeys.uid.rawValue : friend,
                FriendListItem.FirestoreKeys.isIgnored.rawValue : isIgnored],
                                      merge: true, completion: completion)
    }
}
