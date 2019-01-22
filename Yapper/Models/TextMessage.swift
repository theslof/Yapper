//
//  TextMessage.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-18.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

struct TextMessage: Message {
    private static let TAG = "TextMessage"
    static let type: MessageType = .text
    let sender: String
    let timestamp: Timestamp
    let data: String
    
    init(sender: String, timestamp: Timestamp, data: String) {
        self.sender = sender
        self.timestamp = timestamp
        self.data = data
    }
    
    init?(from dictionary: [String : Any]) {
        guard
            let typeString = dictionary[MessageKeys.type.rawValue] as? String,
            let type = MessageType(rawValue: typeString),
            type == TextMessage.type,
            let sender = dictionary[MessageKeys.sender.rawValue] as? String,
            let timestamp = dictionary[MessageKeys.timestamp.rawValue] as? Timestamp,
            let data = dictionary[MessageKeys.data.rawValue] as? String
            else {
                Log.e(TextMessage.TAG, "Failed to parse message: \(dictionary.description)")
                return nil }
        self.init(sender: sender, timestamp: timestamp, data: data)
    }
    
    init?(from doc: DocumentSnapshot?){
        guard
            let data: [String : Any] = doc?.data()
            else { return nil }
        self.init(from: data)
    }

    func getView() -> UIView {
        let view = UITextView(frame: .zero)
        view.text = data
        return view
    }
    
    func toDictionary() -> [String : Any] {
        return [
            MessageKeys.type.rawValue : TextMessage.type.rawValue,
            MessageKeys.sender.rawValue : sender,
            MessageKeys.timestamp.rawValue : timestamp,
            MessageKeys.data.rawValue : data
        ]
    }
}
