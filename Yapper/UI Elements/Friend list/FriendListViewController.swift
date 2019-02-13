//
//  FriendListViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-08.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

class FriendListViewController: ThemedViewController {
    private static let TAG = "FriendListViewController"
    @IBOutlet weak var tableView: UITableView!
    
    var sections = [NSLocalizedString("friends", comment: "Friends"), NSLocalizedString("ignored", comment: "Ignored"), NSLocalizedString("others", comment: "Others")]
    var friends: [User] = []
    var ignored: [User] = []
    var others: [User] = []
    var filtered: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = Theme.currentTheme.background
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            dismiss(animated: true, completion: nil)
            return }
        
        DatabaseManager.shared.users.getUsers { users, error in
            if let users = users {
                self.friends = []
                self.ignored = []
                self.others = []
                
                let friends = DatabaseManager.shared.users.getFriendlist()
                
                users.forEach {user in
                    if user.uid == uid {
                        return
                    }
                    
                    if friends[user.uid]?.isFriend ?? false {
                        self.friends.append(user)
                    } else if friends[user.uid]?.isIgnored ?? false {
                        self.ignored.append(user)
                    } else {
                        self.others.append(user)
                    }
                }
                self.filterUsersBy(string: nil)
            }
        }
    }
    
    private func filterUsersBy(string: String?) {
        filtered = []
        if let words = string?.lowercased().split(separator: " ") {
            filtered.append(contentsOf: friends.filter({ (user) -> Bool in
                words.contains(where: user.displayName.lowercased().contains)
            }))
            filtered.append(contentsOf: ignored.filter({ (user) -> Bool in
                words.contains(where: user.displayName.lowercased().contains)
            }))
            filtered.append(contentsOf: others.filter({ (user) -> Bool in
                words.contains(where: user.displayName.lowercased().contains)
            }))
        }
        
        filtered.sort { (u1, u2) -> Bool in
            return u1.displayName < u2.displayName
        }
        
        self.tableView.reloadData()
    }
    
    
    @IBAction func actionDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension FriendListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !filtered.isEmpty {
            return nil
        }
        return self.sections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !filtered.isEmpty {
            return 1
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filtered.isEmpty {
            return filtered.count
        }
        
        switch section {
        case 0:
            return friends.count
        case 1:
            return ignored.count
        case 2:
            return others.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var user: User?
        
        if !filtered.isEmpty {
            user = filtered[indexPath.row]
        } else {
            switch indexPath.section {
            case 0:
                user = friends[indexPath.row]
            case 1:
                user = ignored[indexPath.row]
            case 2:
                user = others[indexPath.row]
            default:
                break
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? FriendListTableViewCell ?? FriendListTableViewCell()
        
        guard let _user = user else { return cell }
        
        cell.username.text = _user.displayName
        cell.profileImage.image = UIImage(named: _user.profileImage.rawValue)
        cell.favorite.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var user: User?

        if !filtered.isEmpty {
            user = filtered[indexPath.row]
        } else {
            switch indexPath.section {
            case 0:
                user = friends[indexPath.row]
            case 1:
                user = ignored[indexPath.row]
            case 2:
                user = others[indexPath.row]
            default:
                break
            }
        }

        if let uid = user?.uid,
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileViewController") as? ProfileViewController {
            controller.uid = uid
            self.present(controller, animated: true, completion: nil)
        } else {
            Log.e(FriendListViewController.TAG, "Tapped on user, failed to launch profile viewer")
        }

    }
}

extension FriendListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterUsersBy(string: searchText.isEmpty ? nil : searchText)
    }
}
