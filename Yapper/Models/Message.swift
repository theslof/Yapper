//
//  Message.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-18.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

protocol Message {
    static var type: MessageType { get }
    var sender: String { get }
    var timestamp: Timestamp { get }
    var data: String { get }
    
    func getView() -> UIView
    func toDictionary() -> [String : Any]
}

enum MessageType: String {
    case text = "text"
}

enum MessageKeys: String {
    case type = "type"
    case sender = "sender"
    case timestamp = "timestamp"
    case data = "data"
}
