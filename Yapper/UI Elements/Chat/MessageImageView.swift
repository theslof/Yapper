//
//  MessageImageView.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-30.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class MessageImageView: UIView {
    private static let placeholder = "image_placeholder"
    private var heightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var message: Message?
    private var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        imageView = UIImageView(frame: self.frame)
        self.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.center = self.center
        imageView.isUserInteractionEnabled = true
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = Theme.currentTheme.cornerRadius / 2
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: Theme.currentTheme.margin),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Theme.currentTheme.margin),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Theme.currentTheme.margin),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Theme.currentTheme.margin)
            ])
        
        let placeholderImage: UIImage = UIImage(named: MessageImageView.placeholder)!
        self.imageView.image = placeholderImage
    }
    
    func loadImageFrom(message: Message) {
        guard let url = URL(string: message.data) else { return }
        self.message = message
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData = NSData(contentsOf: url)!
            DispatchQueue.main.async {
                let image = UIImage(data: imageData as Data)
                self.imageView.image = image
            }
        }
    }
}
