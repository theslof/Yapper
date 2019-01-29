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
    private static let placeholder = "image_placeholder"
    static let type: MessageType = .image
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
            type == ImageMessage.type,
            let sender = dictionary[MessageKeys.sender.rawValue] as? String,
            let timestamp = dictionary[MessageKeys.timestamp.rawValue] as? Timestamp,
            let data = dictionary[MessageKeys.data.rawValue] as? String
            else {
                Log.e(ImageMessage.TAG, "Failed to parse message: \(dictionary.description)")
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
        let view = UIView(frame: .zero)
        let imageView = UIImageView(frame: .zero)
        view.addSubview(imageView)
        view.contentMode = .scaleAspectFit
        imageView.contentMode = .scaleAspectFit
        imageView.center = view.center

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: Theme.currentTheme.margin),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Theme.currentTheme.margin),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.currentTheme.margin),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.currentTheme.margin)
            ])

        let placeholderImage: UIImage = UIImage(named: ImageMessage.placeholder)!
        
        imageView.image = placeholderImage
        
        guard let url = URL(string: self.data) else { return view }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData = NSData(contentsOf: url)!
            DispatchQueue.main.async {
                let image = UIImage(data: imageData as Data)
                imageView.image = image
                
//                let width = min(imageView.frame.width, image?.size.width ?? 0)
//                let ratio = (image?.size.height ?? 1) / (image?.size.width ?? 1)
//                let height = width * ratio
                
//                view.frame.size = CGSize(width: width, height: height)
//                imageView.sizeToFit()
//                view.sizeToFit()
            }
        }
        view.backgroundColor = Theme.currentTheme.backgroundText
        view.isOpaque = true
        
        return view
    }
    
    func toDictionary() -> [String : Any] {
        return [
            MessageKeys.type.rawValue : ImageMessage.type.rawValue,
            MessageKeys.sender.rawValue : sender,
            MessageKeys.timestamp.rawValue : timestamp,
            MessageKeys.data.rawValue : data
        ]
    }
}
