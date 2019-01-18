//
//  Conversation.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-18.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation
import Firebase

struct Conversation {
    private static let TAG = "ConversationManager"
    let members: [String]
    let lastUpdated: Timestamp
    let messages: [Message]
    
    init(members: [String], lastUpdated: Timestamp, messages: [Message]) {
        self.members = members
        self.lastUpdated = lastUpdated
        self.messages = messages
    }
    
    init(members: [String], lastUpdated: Timestamp, messages: [[String : Any]]) {
        self.members = members
        self.lastUpdated = lastUpdated
        self.messages = messages.compactMap(Conversation.parse(message: ))
    }
    
    init?(from dictionary: [String : Any]) {
        guard
            let members = dictionary[FirestoreKeys.members.rawValue] as? [String],
            let lastUpdated = dictionary[FirestoreKeys.lastUpdated.rawValue] as? Date,
            let messages = dictionary[FirestoreKeys.messages.rawValue] as? [[String : Any]]
            else {
                Log.e(Conversation.TAG, "Unable to parse dictionary to Converstion")
                return nil }
        self.init(members: members, lastUpdated: Timestamp(date: lastUpdated), messages: messages)
    }
    
    init?(from doc: DocumentSnapshot?){
        guard
            let data: [String : Any] = doc?.data()
            else {
                Log.e(Conversation.TAG, "Unable to read data")
                return nil
        }
        self.init(from: data)
    }
    
    func getView() -> UIView {
        return UIView(frame: .zero)
    }
    
    func toDictionary() -> [String : Any] {
        return [
            FirestoreKeys.members.rawValue : members,
            FirestoreKeys.lastUpdated.rawValue : lastUpdated,
            FirestoreKeys.messages.rawValue : messages.map { $0.toDictionary() }
        ]
    }
    
    static func parse(message: [String : Any]) -> Message? {
        if let type = message[MessageKeys.type.rawValue] as? MessageType {
            switch type {
            case .text:
                if let message = TextMessage(from: message) { return message }
            }
        }
        return nil
    }
    
    enum FirestoreKeys: String {
        case members = "members"
        case lastUpdated = "lastUpdated"
        case messages = "messages"
    }
}
