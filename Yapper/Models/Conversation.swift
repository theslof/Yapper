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
    var id: String?
    let members: [String]
    let owners: [String]
    let lastUpdated: Timestamp
    
    init(id: String? = nil, members: [String], owners: [String], lastUpdated: Timestamp) {
        self.id = id
        self.owners = owners
        self.members = members
        self.lastUpdated = lastUpdated
    }
    
    init(id: String? = nil, members: [String]) {
        self.init(id: id, members: members, owners: members, lastUpdated: Timestamp.init())
    }

    init?(from dictionary: [String : Any]) {
        guard
            let members = dictionary[FirestoreKeys.members.rawValue] as? [String] else {
                Log.e(Conversation.TAG, "Unable to parse dictionary to Converstion, key: members")
                return nil }
        guard
            let owners = dictionary[FirestoreKeys.owners.rawValue] as? [String] else {
                Log.e(Conversation.TAG, "Unable to parse dictionary to Converstion, key: owners")
                Log.e(Conversation.TAG, dictionary[FirestoreKeys.owners.rawValue].debugDescription)
                return nil }
        guard
            let lastUpdated = dictionary[FirestoreKeys.lastUpdated.rawValue] as? Timestamp else {
                Log.e(Conversation.TAG, "Unable to parse dictionary to Converstion, key: lastUpdated")
                return nil }
        guard
            let id = dictionary[FirestoreKeys.id.rawValue] as? String else {
                Log.e(Conversation.TAG, "Unable to parse dictionary to Converstion, key: id")
                Log.e(Conversation.TAG, dictionary[FirestoreKeys.id.rawValue].debugDescription)
                return nil }
        self.init(id: id, members: members, owners: owners, lastUpdated: lastUpdated)
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
        var dict: [String: Any] = [
            FirestoreKeys.members.rawValue : members,
            FirestoreKeys.owners.rawValue : owners,
            FirestoreKeys.lastUpdated.rawValue : lastUpdated,
        ]
        if let id = id {
            dict[FirestoreKeys.id.rawValue] = id
        }
        return dict
    }
    
    static func parse(message: [String : Any]) -> Message? {
        if
            let typeString = message[MessageKeys.type.rawValue] as? String,
            let type = MessageType(rawValue: typeString) {
            switch type {
            case .text:
                if let message = TextMessage(from: message) { return message }
            case .image:
                if let message = ImageMessage(from: message) { return message }
            }
        }
        return nil
    }
    
    enum FirestoreKeys: String {
        case id = "id"
        case members = "members"
        case owners = "owners"
        case lastUpdated = "lastUpdated"
    }
}
