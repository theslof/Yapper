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
    private let db: Firestore
    
    init(database: Firestore) {
        self.db = database
    }
    
    /**
     * Register a new listener for all conversations where the user is a member
     */
    func getConversations(listener: @escaping FIRQuerySnapshotBlock) -> ListenerRegistration? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection(FirebaseDefaults.CollectionConversations.rawValue)
            .whereField("members", arrayContains: uid)
            .addSnapshotListener(listener)
    }
    
    /**
     * Start a new conversation where all users in the members array are registered as members/owners
     */
    func startConversation(user: String, members: [String] = []) -> String {
        var members = members
        if !members.contains(user) {
            members.append(user)
        }
        var conversation = Conversation(members: members)
        let doc = db.collection(FirebaseDefaults.CollectionConversations.rawValue).document()
        conversation.id = doc.documentID
        doc.setData(conversation.toDictionary())
        return doc.documentID
    }
    
    /**
     * Add the user as a member in a conversation
     */
    func addUsersToConversation(users: [String], conversation: String, completion: ((Error?) -> Void)? = nil) {
        db.collection(FirebaseDefaults.CollectionConversations.rawValue).document(conversation)
            .updateData([Conversation.FirestoreKeys.members.rawValue: FieldValue.arrayUnion(users)], completion: completion)
    }
    
    /**
     * Register a listener that listens for all messages that belong to a conversation
     */
    func getMessages(for conversation: String, listener: @escaping FIRQuerySnapshotBlock) -> ListenerRegistration{
        return db
            .collection(FirebaseDefaults.CollectionConversations.rawValue).document(conversation)
            .collection(FirebaseDefaults.CollectionMessages.rawValue).addSnapshotListener(listener)
    }
    
    /**
     * Add a message to a conversation
     */
    func add(message: Message, to conversation: String) {
        let doc = db
            .collection(FirebaseDefaults.CollectionConversations.rawValue)
            .document(conversation).collection(FirebaseDefaults.CollectionMessages.rawValue)
            .document()
        var messageData = message.toDictionary()
        messageData[MessageKeys.mid.rawValue] = doc.documentID
        doc.setData(messageData) { (error) in
                if let error = error {
                    Log.e(ConversationManager.TAG, error.localizedDescription)
                } else {
                    self.setLastUpdatedTo(message.timestamp, for: conversation)
                }
        }
    }
    
    /**
     * Update the lastUpdated field in a conversation
     */
    private func setLastUpdatedTo(_ timestamp: Timestamp, for conversation: String) {
        self.db
            .collection(FirebaseDefaults.CollectionConversations.rawValue)
            .document(conversation)
            .updateData([Conversation.FirestoreKeys.lastUpdated.rawValue : timestamp]) { error in
                if let error = error {
                    Log.e(ConversationManager.TAG, error.localizedDescription)
                }
        }
    }
    
    /**
     * Delete a message from a conversation
     */
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
