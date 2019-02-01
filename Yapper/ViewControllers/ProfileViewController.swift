//
//  ProfileViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-31.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImage: RoundedImage!
    @IBOutlet weak var displayName: UILabel!
    
    
    var uid: String?
    var user: User? {
        didSet {
            redrawViews()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let uid = uid else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        self.view.backgroundColor = Theme.currentTheme.background
        self.displayName.textColor = Theme.currentTheme.text
        
//        profileImage.recalculateSize()
        
        DatabaseManager.shared.users.getUser(uid: uid) { (user, error) in
            if let user = user {
                self.user = user
            } else if let error = error {
                Log.e("ProfileViewController", error.localizedDescription)
            }
        }
    }
    
    private func redrawViews(){
        profileImage.image = UIImage(named: user?.profileImage.rawValue ?? "placeholder")
        displayName.text = user?.displayName ?? "Unknown user"
    }
    
    @IBAction func actionDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
