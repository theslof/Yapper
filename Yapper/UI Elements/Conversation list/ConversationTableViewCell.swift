//
//  ConversationTableViewCell.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-21.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

class ConversationTableViewCell: UITableViewCell {
    private static let TAG = "ConversationTableViewCell"
    private var profileImages: [RoundedImage] = []
    private var numberImage: RoundedLabel?
    private var title: UILabel?
    private var timeLabel: UILabel?
    
    var conversation: Conversation? {
        willSet {
            clearViews()
        }
        didSet {
            if let conversation = conversation {
                drawViews(for: conversation)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        clearViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func clearViews() {
        profileImages.forEach { (image) in
            image.removeFromSuperview()
        }
        profileImages.removeAll()
        
        self.numberImage?.removeFromSuperview()
        self.numberImage = nil
        
        self.title?.removeFromSuperview()
        self.title = nil
        
        self.timeLabel?.removeFromSuperview()
        self.timeLabel = nil
    }
    
    private func drawViews(for conversation: Conversation) {
        let offset = -16
        let size: CGFloat = 44
        self.contentView.backgroundColor = Theme.currentTheme.background
        
        DatabaseManager.shared.users.getUsersFor(conversation.members, completion: { (users, error) in
            guard let users = users, let currentUser = Auth.auth().currentUser?.uid else {
                if let error = error {
                    Log.e(ConversationTableViewCell.TAG, error.localizedDescription)
                }
                return
            }
            
            var filtered = users.filter { $0.uid != currentUser }
            
            var last: UIView?
            let extras = max(0, filtered.count - 5)
            filtered = Array(filtered.dropLast(extras))

            // Draw profile images for the first five members
            filtered.forEach({ (user) in
                let image = ProfileImage(frame: .zero, size: size)
                image.translatesAutoresizingMaskIntoConstraints = false
                self.contentView.addSubview(image)
                self.profileImages.append(image)
                
                if let last = last {
                    NSLayoutConstraint.activate([
                        image.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                        image.leadingAnchor.constraint(equalTo: last.trailingAnchor, constant: CGFloat(offset)),
                        image.heightAnchor.constraint(equalToConstant: size),
                        image.widthAnchor.constraint(equalTo: image.heightAnchor)
                        ])
                } else {
                NSLayoutConstraint.activate([
                    image.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                    image.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Theme.currentTheme.margin),
                    image.heightAnchor.constraint(equalToConstant: size),
                    image.widthAnchor.constraint(equalTo: image.heightAnchor)
                    ])
                }
                last = image
                image.image = UIImage(named: user.profileImage.rawValue)
            })

            // Draw a rounded label with the number of conversation members > 5
            if extras > 0 {
                let image = RoundedLabel(frame: .zero, size: size)
                self.numberImage = image
                self.contentView.addSubview(image)
                image.text = "+\(extras)"
                image.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    image.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                    image.leadingAnchor.constraint(equalTo: last!.trailingAnchor, constant: CGFloat(offset)),
                    image.heightAnchor.constraint(equalToConstant: size),
                    image.widthAnchor.constraint(equalTo: image.heightAnchor)
                    ])
            }
            
            // Add a conversation title if there's only one other member
            if filtered.count == 1,
                let other = filtered.first(where: { $0.uid != currentUser }),
                let _last = last
            {
                let title = UILabel(frame: .zero)
                title.text = other.displayName
                
                self.contentView.addSubview(title)
                title.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    title.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                    title.leadingAnchor.constraint(equalTo: _last.trailingAnchor, constant: Theme.currentTheme.margin),
                    ])
                last = title
                self.title = title
            }
            
            // Add a timestamp
            if let last = last {
                let timestamp = ThemedLabel(frame: .zero)
                timestamp.text = formattedTimeFrom(timestamp: conversation.lastUpdated)
                timestamp.font = timestamp.font.withSize(10.0)
                timestamp.textAlignment = .right
                
                if let cid = conversation.id {
                    let lastUpdated = SaveData.shared.getLastUpdated(forConversation: cid) ?? Timestamp(seconds: 0, nanoseconds: 0)
                    if lastUpdated.dateValue() < conversation.lastUpdated.dateValue() {
                        timestamp.textColor = Theme.currentTheme.primary
                    }
                }

                
                self.contentView.addSubview(timestamp)
                timestamp.setContentCompressionResistancePriority(.required, for: .horizontal)
                timestamp.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    timestamp.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                    timestamp.leadingAnchor.constraint(equalTo: last.trailingAnchor, constant: Theme.currentTheme.margin),
                    timestamp.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -Theme.currentTheme.margin)
                    ])
                self.timeLabel = timestamp
            }
        })
    }

}
