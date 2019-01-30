//
//  TextMessage.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-18.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

struct ImageMessage: Message {
    private static let TAG = "ImageMessage"
    static let type: MessageType = .image
    let mid: String?
    let sender: String
    let timestamp: Timestamp
    let data: String
    
    init(mid: String? = nil, sender: String, timestamp: Timestamp, data: String) {
        self.mid = mid
        self.sender = sender
        self.timestamp = timestamp
        self.data = data
    }
    
    init?(from dictionary: [String : Any]) {
        guard
            let mid = dictionary[MessageKeys.mid.rawValue] as? String,
            let typeString = dictionary[MessageKeys.type.rawValue] as? String,
            let type = MessageType(rawValue: typeString),
            type == ImageMessage.type,
            let sender = dictionary[MessageKeys.sender.rawValue] as? String,
            let timestamp = dictionary[MessageKeys.timestamp.rawValue] as? Timestamp,
            let data = dictionary[MessageKeys.data.rawValue] as? String
            else {
                Log.e(ImageMessage.TAG, "Failed to parse message: \(dictionary.description)")
                return nil }
        self.init(mid: mid.isEmpty ? nil : mid, sender: sender, timestamp: timestamp, data: data)
    }
    
    init?(from doc: DocumentSnapshot?){
        guard
            let data: [String : Any] = doc?.data()
            else { return nil }
        self.init(from: data)
    }
    
    func getView() -> UIView {
        let view = UIView(frame: .zero)
        let imageView = MessageImageView(frame: .zero)
        view.addSubview(imageView)
        view.contentMode = .scaleAspectFit
        imageView.contentMode = .scaleAspectFill
        imageView.center = view.center
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = Theme.currentTheme.cornerRadius / 2

        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: Theme.currentTheme.margin),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Theme.currentTheme.margin),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.currentTheme.margin),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.currentTheme.margin)
            ])
        
        imageView.loadImageFrom(message: self)
        
        view.backgroundColor = Theme.currentTheme.backgroundText
        view.isOpaque = true
        
        return view
    }
    
    func toDictionary() -> [String : Any] {
        return [
            MessageKeys.mid.rawValue : mid ?? "",
            MessageKeys.type.rawValue : ImageMessage.type.rawValue,
            MessageKeys.sender.rawValue : sender,
            MessageKeys.timestamp.rawValue : timestamp,
            MessageKeys.data.rawValue : data
        ]
    }
}
