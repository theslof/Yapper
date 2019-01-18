//
//  ConversationManager.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-18.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation
import Firebase

class ConversationManager {
    let db: Firestore
    
    init(database: Firestore) {
        self.db = database
    }
    
    func getConversations(listener: @escaping FIRQuerySnapshotBlock) -> ListenerRegistration {
        return db.collection(FirebaseDefaults.CollectionConversations.rawValue).addSnapshotListener(listener)
    }
}
