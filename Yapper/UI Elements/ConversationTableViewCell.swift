//
//  ConversationTableViewCell.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-21.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {    
    private var profileImages: [RoundedImage] = []
    private var numberImage: RoundedLabel?
    
    var users: [String] = [] {
        willSet {
            clearProfileImages()
        }
        didSet {
            drawProfileImages()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func clearProfileImages() {
        profileImages.forEach { (image) in
            image.removeFromSuperview()
        }
        self.numberImage?.removeFromSuperview()
        self.numberImage = nil
        profileImages = []
    }
    
    private func drawProfileImages() {
        let offset = -16
        let size: CGFloat = 44

        DatabaseManager.shared.users.getUsers(completion: { (users, error) in
            var filtered = users.filter({ (user) -> Bool in
                self.users.contains(user.uid)
            })
            var last: RoundedImage?
            let extras = max(0, filtered.count - 5)
            filtered = Array(filtered.dropLast(extras))
            filtered.forEach({ (user) in
                let image = RoundedImage(frame: .zero, size: size)
                image.translatesAutoresizingMaskIntoConstraints = false
                self.contentView.addSubview(image)
                self.profileImages.append(image)
                
                if let last = last {
                    NSLayoutConstraint.activate([
                        image.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                        image.leadingAnchor.constraint(equalTo: last.trailingAnchor, constant: CGFloat(offset)),
                        image.heightAnchor.constraint(equalToConstant: size),
                        image.widthAnchor.constraint(equalTo: image.heightAnchor)
                        ])
                } else {
                NSLayoutConstraint.activate([
                    image.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                    image.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Theme.currentTheme.margin),
                    image.heightAnchor.constraint(equalToConstant: size),
                    image.widthAnchor.constraint(equalTo: image.heightAnchor)
                    ])
                }
                last = image
                image.image = UIImage(named: user.profileImage.rawValue)
            })
            if extras > 0 {
                let image = RoundedLabel(frame: .zero, size: size)
                self.numberImage = image
                self.contentView.addSubview(image)
                image.text = "+\(extras)"
                image.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    image.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                    image.leadingAnchor.constraint(equalTo: last!.trailingAnchor, constant: CGFloat(offset)),
                    image.heightAnchor.constraint(equalToConstant: size),
                    image.widthAnchor.constraint(equalTo: image.heightAnchor)
                    ])
            }

        })
    }

}
