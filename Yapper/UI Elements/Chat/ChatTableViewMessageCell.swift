//
//  ChatTableViewCell.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-23.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

class ChatTableViewMessageCell: UITableViewCell{
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    
    func set(message: Message) {
    }

    func getProfileImageView() -> ProfileImage? {
        return nil
    }
}
