//
//  UserPickerViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-06.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

class UserPickerViewController: ThemedViewController {
    private static let TAG = "UserPickerViewController"
    @IBOutlet weak var tableView: UserPickerTableView!
    
    var users: [String] = []
    var friends: [String] = []
    var delegate: UserPickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = Theme.currentTheme.background

        guard let uid = Auth.auth().currentUser?.uid else { return }

        DatabaseManager.shared.users.getFriendlistFor(uid) { friendItems, error in
            if let friendItems = friendItems {
                friendItems.forEach { item in
                    self.friends.append(item.uid)
                }
            } else if let error = error {
                Log.e(UserPickerViewController.TAG, error.localizedDescription)
            }

            DatabaseManager.shared.users.getUsers { users, error in
                if let users = users {
                    let notFriends: [String] = users.compactMap { user -> String? in
                        return user.uid == uid || self.friends.contains(user.uid) ? nil : user.uid
                    }

                    self.users.append(contentsOf: self.friends)
                    self.users.append(contentsOf: notFriends)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func actionAdd(_ sender: Any) {
        let users: [String] = tableView.indexPathsForSelectedRows?.compactMap({ indexPath -> String in
            return self.users[indexPath.row]
        }) ?? []
        delegate?.userPicker(self, didFinishPickingUsersWithUsers: users)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension UserPickerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UserPickerTableViewCell ?? UserPickerTableViewCell()

        DatabaseManager.shared.users.getUser(uid: users[indexPath.row]) { user, error in
            if let user = user {
                cell.username.text = user.displayName
                cell.profileImage.image = UIImage(named: user.profileImage.rawValue)
                cell.favorite.isHidden = !self.friends.contains(user.uid)
            }
        }
        
        return cell
    }
}
