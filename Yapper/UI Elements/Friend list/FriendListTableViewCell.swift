//
//  FriendListTableViewCell.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-08.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class FriendListTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: ProfileImage!
    @IBOutlet weak var username: ThemedLabel!
    @IBOutlet weak var favorite: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setTheme()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setTheme() {
        self.contentView.backgroundColor = Theme.currentTheme.background
    }
    
}
