//
//  DatabaseManager.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-17.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation
import Firebase

class DatabaseManager {
    static let shared: DatabaseManager = DatabaseManager()
    private let db: Firestore
    let users: UserManager
    let auth: LoginManager
    let messages: ConversationManager
    
    private init() {
        db = Firestore.firestore()
        users = UserManager(database: db)
        auth = LoginManager()
        messages = ConversationManager(database: db)
    }    
}
