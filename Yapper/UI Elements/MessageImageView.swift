//
//  MessageImageView.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-30.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class MessageImageView: UIImageView {
    private static let placeholder = "image_placeholder"
    private var heightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var message: Message?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let placeholderImage: UIImage = UIImage(named: MessageImageView.placeholder)!
        self.image = placeholderImage
    }
    
    func loadImageFrom(message: Message) {
        guard let url = URL(string: message.data) else { return }
        self.message = message
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData = NSData(contentsOf: url)!
            DispatchQueue.main.async {
                let image = UIImage(data: imageData as Data)
                self.image = image
            }
        }
    }
}
