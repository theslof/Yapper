//
//  ProfileViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-31.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: ThemedViewController {
    private static let TAG = "ProfileViewController"
    
    @IBOutlet weak var profileImage: RoundedImage!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var switchFriends: UISwitch!
    @IBOutlet weak var switchIgnored: UISwitch!
    
    
    var uid: String?
    var user: User? {
        didSet {
            redrawViews()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let uid = uid, let cuid = Auth.auth().currentUser?.uid else {
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
                Log.e(ProfileViewController.TAG, error.localizedDescription)
            }
        }
        
        DatabaseManager.shared.users.getFriendlistFor(cuid) { (friendList, error) in
            if let friendList = friendList, let item = friendList.first(where:
                { item -> Bool in item.uid == uid }) {
                self.switchFriends.isOn = item.isFriend
                self.switchIgnored.isOn = item.isIgnored
            } else if let error = error {
                Log.e(ProfileViewController.TAG, error.localizedDescription)
            }
        }
    }
    
    private func redrawViews(){
        profileImage.image = UIImage(named: user?.profileImage.rawValue ?? "placeholder")
        displayName.text = user?.displayName ?? "Unknown user"
    }
    
    @IBAction func actionToggleFriends(_ sender: UISwitch) {
        guard let uid = uid, let cuid = Auth.auth().currentUser?.uid else {
            dismiss(animated: true, completion: nil)
            return
        }

        if sender.isOn {
            DatabaseManager.shared.users.setFriendFor(cuid, friend: uid, isFriend: true) { (error) in
                if let error = error {
                    Log.e(ProfileViewController.TAG, error.localizedDescription)
                    sender.setOn(false, animated: true)
                }
            }
            DatabaseManager.shared.users.setIgnoredFor(cuid, friend: uid, isIgnored: false) { (error) in
                if let error = error {
                    Log.e(ProfileViewController.TAG, error.localizedDescription)
                } else {
                    self.switchIgnored.setOn(false, animated: true)
                }
            }
        } else {
            DatabaseManager.shared.users.setFriendFor(cuid, friend: uid, isFriend: false) { (error) in
                if let error = error {
                    Log.e(ProfileViewController.TAG, error.localizedDescription)
                    sender.setOn(true, animated: true)
                }
            }
        }
    }
    
    @IBAction func actionToggleIgnored(_ sender: UISwitch) {
        guard let uid = uid, let cuid = Auth.auth().currentUser?.uid else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        if sender.isOn {
            DatabaseManager.shared.users.setIgnoredFor(cuid, friend: uid, isIgnored: true) { (error) in
                if let error = error {
                    Log.e(ProfileViewController.TAG, error.localizedDescription)
                    sender.setOn(false, animated: true)
                }
            }
            DatabaseManager.shared.users.setFriendFor(cuid, friend: uid, isFriend: false) { (error) in
                if let error = error {
                    Log.e(ProfileViewController.TAG, error.localizedDescription)
                } else {
                    self.switchFriends.setOn(false, animated: true)
                }
            }
        } else {
            DatabaseManager.shared.users.setIgnoredFor(cuid, friend: uid, isIgnored: false) { (error) in
                if let error = error {
                    Log.e(ProfileViewController.TAG, error.localizedDescription)
                    sender.setOn(true, animated: true)
                }
            }
        }
    }
    
    @IBAction func actionDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
