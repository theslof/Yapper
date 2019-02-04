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
    lazy var users: UserManager = UserManager(database: db)
    lazy var auth: LoginManager = LoginManager()
    lazy var messages: ConversationManager = ConversationManager(database: db)
    
    private init() {
        db = Firestore.firestore()
    }
}
