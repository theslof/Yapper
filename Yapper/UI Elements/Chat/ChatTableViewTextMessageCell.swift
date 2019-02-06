//
//  ChatTableViewCell.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-23.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

class ChatTableViewTextMessageCell: ChatTableViewMessageCell {
    var profileImage: ProfileImage?
    var userName: ThemedLabel?
    var timestamp: ThemedLabel?
    var view: UIView?
    let size: CGFloat = 44.0
    
    var _constraints: [NSLayoutConstraint] = []

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage?.removeFromSuperview()
        userName?.removeFromSuperview()
        timestamp?.removeFromSuperview()
        view?.removeFromSuperview()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func set(message: Message) {
        guard let user = Auth.auth().currentUser else { return }
        self.backgroundColor = nil
        self.isOpaque = false
        self.layer.masksToBounds = true
        
        let messageView = message.getView()
        self.contentView.addSubview(messageView)
        self.view = messageView
        messageView.layer.cornerRadius = Theme.currentTheme.cornerRadius
        messageView.layer.masksToBounds = false
        messageView.layer.shadowColor = Theme.currentTheme.text.cgColor
        messageView.layer.shadowOpacity = 0.1
        messageView.layer.shadowRadius = 1.5
        messageView.layer.shadowOffset = CGSize(width: 0, height: 1.5)


        let profileView = ProfileImage(frame: .zero, size: size)
        self.contentView.addSubview(profileView)
        self.profileImage = profileView
        profileView.uid = message.sender
        profileView.isUserInteractionEnabled = true

        let usernameView = ThemedLabel(frame: .zero)
        self.contentView.addSubview(usernameView)
        self.userName = usernameView
        usernameView.textColor = Theme.currentTheme.textSecondary

        let timeView = ThemedLabel(frame: .zero)
        self.contentView.addSubview(timeView)
        self.timestamp = timeView
        timeView.textColor = Theme.currentTheme.textSecondary
        timeView.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeView.font = timeView.font.withSize(10.0)

        messageView.translatesAutoresizingMaskIntoConstraints = false
        profileView.translatesAutoresizingMaskIntoConstraints = false
        usernameView.translatesAutoresizingMaskIntoConstraints = false
        timeView.translatesAutoresizingMaskIntoConstraints = false

        if user.uid == message.sender {
            loadRightConstraints()
        } else {
            loadLeftConstraints()
        }
        
        DatabaseManager.shared.users.getUser(uid: message.sender) { (user, error) in
            if let user = user {
                profileView.image = UIImage(named: user.profileImage.rawValue)
                usernameView.text = user.displayName
                
                timeView.text = formattedTimeFrom(timestamp: message.timestamp)
            }
        }
        
        userName?.textColor = Theme.currentTheme.text
        timestamp?.textColor = Theme.currentTheme.text
    }
    
    var commonConstraint: [NSLayoutConstraint] {
        guard
            let profileView = profileImage,
            let usernameView = userName,
            let timeView = timestamp,
            let messageView = view
            else { return [] }
        
        return [
            profileView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Theme.currentTheme.margin),
            profileView.heightAnchor.constraint(equalToConstant: size),
            profileView.widthAnchor.constraint(equalTo: profileView.heightAnchor),
            
            usernameView.topAnchor.constraint(equalTo: profileView.topAnchor),
            usernameView.heightAnchor.constraint(equalToConstant: 14),
            
            timeView.bottomAnchor.constraint(equalTo: usernameView.bottomAnchor),
            
            messageView.topAnchor.constraint(equalTo: usernameView.bottomAnchor, constant: Theme.currentTheme.margin / 2),
            messageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Theme.currentTheme.margin)
            ]
    }
    
    func loadRightConstraints() {
        guard
            let profileView = profileImage,
            let usernameView = userName,
            let timeView = timestamp,
            let messageView = view
            else { return }
        
        timeView.textAlignment = .left
        usernameView.textAlignment = .right
        messageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        NSLayoutConstraint.deactivate(_constraints)
        
        _constraints = [
            profileView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -Theme.currentTheme.margin),
            
            usernameView.trailingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: -Theme.currentTheme.margin),
            
            timeView.trailingAnchor.constraint(equalTo: usernameView.leadingAnchor, constant: -Theme.currentTheme.margin),
            timeView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: Theme.currentTheme.margin / 2),
            
            messageView.trailingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: -Theme.currentTheme.margin),
            messageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.readableContentGuide.leadingAnchor, constant: Theme.currentTheme.margin)
        ]
        
        _constraints.append(contentsOf: commonConstraint)
        
        NSLayoutConstraint.activate(_constraints)
    }
    
    func loadLeftConstraints() {
        guard
            let profileView = profileImage,
            let usernameView = userName,
            let timeView = timestamp,
            let messageView = view
            else { return }

        timeView.textAlignment = .right
        usernameView.textAlignment = .left
        messageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]

        NSLayoutConstraint.deactivate(_constraints)

        _constraints = [
            profileView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Theme.currentTheme.margin),
            
            usernameView.leadingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: Theme.currentTheme.margin),
            
            timeView.leadingAnchor.constraint(equalTo: usernameView.trailingAnchor, constant: Theme.currentTheme.margin),
            timeView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -Theme.currentTheme.margin / 2),
            
            messageView.leadingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: Theme.currentTheme.margin),
            messageView.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.readableContentGuide.trailingAnchor, constant: -Theme.currentTheme.margin)
        ]
        
        _constraints.append(contentsOf: commonConstraint)
        
        NSLayoutConstraint.activate(_constraints)
    }
    
    override func getProfileImageView() -> ProfileImage? {
        return profileImage
    }
}
