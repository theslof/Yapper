//
//  ChatTableViewCell.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-23.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

class ChatTableViewCell: UITableViewCell {
    var profileImage: RoundedImage?
    var userName: UILabel?
    var timestamp: UILabel?
    var view: UIView?
    
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
    
    func set(message: Message) {
        guard let user = Auth.auth().currentUser else { return }
        let size: CGFloat = 44.0
        self.backgroundColor = nil
        self.isOpaque = false
        self.layer.masksToBounds = true
        
        let messageView = message.getView()
        self.contentView.addSubview(messageView)
        self.view = messageView
        messageView.setContentCompressionResistancePriority(.required, for: .vertical)

        let profileView = RoundedImage(frame: .zero, size: size)
        self.contentView.addSubview(profileView)
        self.profileImage = profileView

        let usernameView = UILabel(frame: .zero)
        self.contentView.addSubview(usernameView)
        self.userName = usernameView
        usernameView.textColor = Theme.currentTheme.textSecondary
        usernameView.setContentCompressionResistancePriority(.required, for: .vertical)

        let timeView = UILabel(frame: .zero)
        self.contentView.addSubview(timeView)
        self.timestamp = timeView
        timeView.textColor = Theme.currentTheme.textSecondary
        timeView.setContentCompressionResistancePriority(.required, for: .vertical)
        timeView.font = timeView.font.withSize(12)

        messageView.translatesAutoresizingMaskIntoConstraints = false
        profileView.translatesAutoresizingMaskIntoConstraints = false
        usernameView.translatesAutoresizingMaskIntoConstraints = false
        timeView.translatesAutoresizingMaskIntoConstraints = false

        messageView.backgroundColor = UIColor.white
        messageView.isOpaque = true
        messageView.layer.cornerRadius = Theme.currentTheme.cornerRadius
        messageView.layer.masksToBounds = true
        messageView.sizeToFit()
        
        let commonConstraints: [NSLayoutConstraint] = [
            profileView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Theme.currentTheme.margin),
            profileView.heightAnchor.constraint(equalToConstant: size),
            profileView.widthAnchor.constraint(equalTo: profileView.heightAnchor),
            
            usernameView.topAnchor.constraint(equalTo: profileView.topAnchor),
            usernameView.heightAnchor.constraint(equalToConstant: 20),
            
            timeView.topAnchor.constraint(equalTo: profileView.topAnchor),
            timeView.heightAnchor.constraint(equalToConstant: 20),
            
            messageView.topAnchor.constraint(equalTo: usernameView.bottomAnchor, constant: Theme.currentTheme.margin),
            messageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Theme.currentTheme.margin),
        ]
        
        let leftConstraints: [NSLayoutConstraint] = [
            profileView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Theme.currentTheme.margin),
            
            usernameView.leadingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: Theme.currentTheme.margin),
            
            timeView.leadingAnchor.constraint(equalTo: usernameView.trailingAnchor, constant: Theme.currentTheme.margin),
            timeView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -Theme.currentTheme.margin),
            
            messageView.leadingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: Theme.currentTheme.margin),
            messageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -Theme.currentTheme.margin)
        ]
        
        let rightConstraints: [NSLayoutConstraint] = [
            profileView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -Theme.currentTheme.margin),
            
            usernameView.trailingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: -Theme.currentTheme.margin),
            
            timeView.trailingAnchor.constraint(equalTo: usernameView.leadingAnchor, constant: -Theme.currentTheme.margin),
            timeView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Theme.currentTheme.margin),
            
            messageView.trailingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: -Theme.currentTheme.margin),
            messageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Theme.currentTheme.margin)
        ]

        NSLayoutConstraint.activate(commonConstraints)
        if user.uid == message.sender {
            timeView.textAlignment = .left
            usernameView.textAlignment = .right
            messageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
            NSLayoutConstraint.deactivate(leftConstraints)
            NSLayoutConstraint.activate(rightConstraints)
        } else {
            timeView.textAlignment = .right
            usernameView.textAlignment = .left
            messageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
            NSLayoutConstraint.deactivate(rightConstraints)
            NSLayoutConstraint.activate(leftConstraints)
        }
        
        DatabaseManager.shared.users.getUser(uid: message.sender) { (user, error) in
            if let user = user {
                profileView.image = UIImage(named: user.profileImage.rawValue)
                usernameView.text = user.displayName
                
                let date = message.timestamp.dateValue()
                let formatter = DateFormatter()
                let calendar = Calendar.current
                
                if calendar.date(Date(), matchesComponents: calendar.dateComponents([.year, .month, .day, .hour], from: date)) {
                    formatter.dateFormat = "HH:mm"
                } else if calendar.date(Date(), matchesComponents: calendar.dateComponents([.year, .month, .day], from: date)) {
                    formatter.dateFormat = "HH:mm"
                } else if calendar.date(Date(), matchesComponents: calendar.dateComponents([.year, .month], from: date)) {
                    formatter.dateFormat = "MMM dd HH:mm"
                } else if calendar.date(Date(), matchesComponents: calendar.dateComponents([.year], from: date)) {
                    formatter.dateFormat = "MMM dd"
                } else {
                    formatter.dateFormat = "MMM dd yyyy"
                }
                timeView.text = formatter.string(from: date)
            }
        }
    }

}
