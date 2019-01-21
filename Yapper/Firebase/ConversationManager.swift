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
    private static let TAG = "ConversationManager"
    let db: Firestore
    
    init(database: Firestore) {
        self.db = database
    }
    
    func getConversations(listener: @escaping FIRQuerySnapshotBlock) -> ListenerRegistration {
        return db.collection(FirebaseDefaults.CollectionConversations.rawValue).addSnapshotListener(listener)
    }
    
    func startConversation(user: String, members: [String] = [], listener: @escaping FIRDocumentSnapshotBlock) -> ListenerRegistration {
        var members = members
        if !members.contains(user) {
            members.append(user)
        }
        let conversation = Conversation(members: members)
        return db.collection(FirebaseDefaults.CollectionConversations.rawValue).addDocument(data: conversation.toDictionary()).addSnapshotListener(listener)
    }
    
    func getMessages(for conversation: String, listener: @escaping FIRQuerySnapshotBlock) -> ListenerRegistration{
        return db
            .collection(FirebaseDefaults.CollectionConversations.rawValue).document(conversation)
            .collection(FirebaseDefaults.CollectionMessages.rawValue).addSnapshotListener(listener)
    }
    
    func add(message: Message, to conversation: String) {
        db
            .collection(FirebaseDefaults.CollectionConversations.rawValue)
            .document(conversation).collection(FirebaseDefaults.CollectionMessages.rawValue)
            .addDocument(data: message.toDictionary()) { (error) in
                if let error = error {
                    Log.e(ConversationManager.TAG, error.localizedDescription)
                }
        }
    }
    
    func delete(message: String, from conversation: String) {
        db
            .collection(FirebaseDefaults.CollectionConversations.rawValue)
            .document(conversation).collection(FirebaseDefaults.CollectionMessages.rawValue)
            .document(message).delete() { (error) in
                if let error = error {
                    Log.e(ConversationManager.TAG, error.localizedDescription)
                }
        }
    }
}
