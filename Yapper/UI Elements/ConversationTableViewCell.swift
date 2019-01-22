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
        let height = self.layer.frame.size.height
        let offset = -20

        DatabaseManager.shared.users.getUsers(completion: { (users, error) in
            var filtered = users.filter({ (user) -> Bool in
                self.users.contains(user.uid)
            })
            var last: RoundedImage?
            let extras = max(0, filtered.count - 5)
            filtered = Array(filtered.dropLast(extras))
            filtered.forEach({ (user) in
                let image = RoundedImage(frame: CGRect(x: 0, y: 0, width: height, height: height))
                image.translatesAutoresizingMaskIntoConstraints = false
                self.contentView.addSubview(image)
                self.profileImages.append(image)
                
                if let last = last {
                    NSLayoutConstraint.activate([
                        image.topAnchor.constraint(equalTo: self.topAnchor),
                        image.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                        image.leadingAnchor.constraint(equalTo: last.trailingAnchor, constant: CGFloat(offset)),
                        image.widthAnchor.constraint(equalTo: image.heightAnchor)
                        ])
                } else {
                NSLayoutConstraint.activate([
                    image.topAnchor.constraint(equalTo: self.topAnchor),
                    image.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    image.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                    image.widthAnchor.constraint(equalTo: image.heightAnchor)
                    ])
                }
                last = image
                image.image = UIImage(named: user.profileImage.rawValue)
            })
            if extras > 0 {
                let image = RoundedLabel(frame: CGRect(x: 0, y: 0, width: height, height: height))
                self.numberImage = image
                self.contentView.addSubview(image)
                image.text = "+\(extras)"
                image.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    image.topAnchor.constraint(equalTo: self.topAnchor),
                    image.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    image.leadingAnchor.constraint(equalTo: last!.trailingAnchor, constant: CGFloat(offset)),
                    image.widthAnchor.constraint(equalTo: image.heightAnchor)
                    ])
            }

        })
    }

}
