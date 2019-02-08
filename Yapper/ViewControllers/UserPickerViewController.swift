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
    @IBOutlet weak var searchBar: UISearchBar!
    
    var users: [String: User] = [:]
    var friends: Set<String> = []
    var filtered: [User] = []
    
    var delegate: UserPickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = Theme.currentTheme.background

        guard let uid = Auth.auth().currentUser?.uid else { return }

        DatabaseManager.shared.users.getFriendlistFor(uid) { friendItems, error in
            if let friendItems = friendItems {
                friendItems.forEach { item in
                    self.friends.insert(item.uid)
                }
            } else if let error = error {
                Log.e(UserPickerViewController.TAG, error.localizedDescription)
            }

            DatabaseManager.shared.users.getUsers { users, error in
                if let users = users {
                    self.users = [:]
                    users.forEach {user in
                        if user.uid == uid {
                            return
                        }
                        
                        self.users[user.uid] = user
                    }
                    self.filterUsersBy(string: nil)
                }
            }
        }
    }
    
    private func filterUsersBy(string: String?) {
        if let words = string?.lowercased().split(separator: " ") {
            filtered = users.values.filter({ (user) -> Bool in
                words.contains(where: user.displayName.lowercased().contains)
            })
        } else {
            filtered = Array(users.values)
        }
        
        filtered.sort { (u1, u2) -> Bool in
            return friends.contains(u1.uid) && !friends.contains(u2.uid) || u1.displayName < u2.displayName
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func actionAdd(_ sender: Any) {
        let users: [String] = tableView.indexPathsForSelectedRows?.compactMap({ indexPath -> String in
            return self.filtered[indexPath.row].uid
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
        return filtered.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UserPickerTableViewCell ?? UserPickerTableViewCell()

        let user: User = filtered[indexPath.row]
        cell.username.text = user.displayName
        cell.profileImage.image = UIImage(named: user.profileImage.rawValue)
        cell.favorite.isHidden = !self.friends.contains(user.uid)
        
        return cell
    }
}

extension UserPickerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterUsersBy(string: searchText.isEmpty ? nil : searchText)
    }
}
