//
//  LoginManager.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-17.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation
import Firebase

class LoginManager {
    private static let TAG = "LoginManager"

    private let auth = Auth.auth()
    
    /**
     * Create a new user account and register the user in the database
     */
    func signUp(email: String, password: String, displayName: String, completion: AuthDataResultCallback?) {
        auth.createUser(withEmail: email, password: password) { (result, error) in
            if let user = result?.user {
                DatabaseManager.shared.users.createUser(user: User(uid: user.uid, displayName: displayName)) { error in
                    completion?(result, error)
                }
            } else {
                completion?(result, error)
            }
        }
    }
    
    /**
     * Sign in to Firebase
     */
    func signIn(withEmail: String, password: String, completion: AuthDataResultCallback?) {
        auth.signIn(withEmail: withEmail, password: password, completion: completion)
    }
    
    /**
     * Sign out from Firebase
     */
    func signOut() {
        do {
            try auth.signOut()
        } catch let error {
            Log.e(LoginManager.TAG, error.localizedDescription)
        }
    }
}
