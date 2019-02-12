//
//  ProfileCollectionViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-12.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

private let profileImages: [String] = ["placeholder", "cat", "chicken", "cow", "deer", "dog", "fox", "monkey", "panda", "pig"]

class ProfileCollectionViewController: UICollectionViewController {
    private static let TAG: String = "ProfileCollectionViewController"

    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = Theme.currentTheme.background
        
        if let uid = Auth.auth().currentUser?.uid {
            DatabaseManager.shared.users.getUser(uid: uid) { (user, error) in
                if let user = user {
                    self.user = user
                    self.collectionView.reloadData()
                }
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profileImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ProfileCollectionViewCell ?? ProfileCollectionViewCell()
    
        // Configure the cell
        let name = profileImages[indexPath.row]
        cell.image.layer.borderColor = Theme.currentTheme.backgroundText.cgColor
        cell.image.image = UIImage(named: name)
        
        if name == user?.profileImage.rawValue {
            cell.image.layer.borderColor = Theme.currentTheme.primary.cgColor
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let name = profileImages[indexPath.row]
        
        if let user = user, let profile = User.ProfileImage(rawValue: name) {
            DatabaseManager.shared.users.updateUser(profileImage: profile, for: user.uid) { (error) in
                if let error = error {
                    Log.e(ProfileCollectionViewController.TAG, error.localizedDescription)
                } else {
                    DatabaseManager.shared.users.getUser(uid: user.uid) { (user, error) in
                        if let user = user {
                            self.user = user
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }

}
