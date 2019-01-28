//
//  MasterViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-09.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

class MasterViewController: UITableViewController {
    private static let TAG = "MasterViewController"

    var detailViewController: DetailViewController? = nil
    
    var data: [Conversation] = []
    
    var conversationsListener: ListenerRegistration? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let yourViewController: LoginViewController = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let window = appDelegate.window!
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = yourViewController
                })
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        conversationsListener = DatabaseManager.shared.messages.getConversations { (snapshot, error) in
            if let conversations = snapshot?.documents {
                self.data = conversations.compactMap(Conversation.init(from: ))
                self.tableView.reloadData()
            } else if let error = error {
                Log.e(MasterViewController.TAG, error.localizedDescription)
            }
        }
        
        tableView.backgroundColor = Theme.currentTheme.background
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = Theme.currentTheme.background
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        conversationsListener?.remove()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let conversation = data[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = conversation
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ConversationTableViewCell
        cell.users = data[indexPath.row].members
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        footer.backgroundColor = Theme.currentTheme.backgroundText
        let button = UIButton(type: .roundedRect)
        button.addTarget(self, action: #selector(actionStartConversation), for: .touchUpInside)
        button.setTitle("Start conversation", for: .normal)
        button.setTitleColor(Theme.currentTheme.primary, for: .normal)
        footer.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: footer.centerYAnchor)
            ])
        return footer
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    @IBAction func actionSignOut(_ sender: Any) {
        DatabaseManager.shared.auth.signOut()
    }
    
    @objc func actionStartConversation() {
        Log.d(MasterViewController.TAG, "Tried to start a new conversation, not yet implemented!")
    }
}

