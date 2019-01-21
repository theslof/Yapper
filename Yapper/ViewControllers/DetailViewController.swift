//
//  DetailViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-09.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {
    private static let TAG = "DetailViewController"
    
    @IBOutlet weak var tableView: ConversationTableView!
    
    var conversation: Conversation?
    var messages: [Message] = []
    var listener: ListenerRegistration?

    func configureView() {
        // Update the user interface for the detail item.
        if let listener = listener {
            listener.remove()
        }
        if let conversation = conversation?.id {
            listener = DatabaseManager.shared.messages.getMessages(for: conversation) { snapshot, error in
                if let messages = snapshot?.documents {
                    Log.d(DetailViewController.TAG, "Messages updated! Found \(messages.count) messages!")
                    self.messages = messages.compactMap { Conversation.parse(message: $0.data()) }
                    self.tableView.reloadData()
                    Log.d(DetailViewController.TAG, self.messages.description)
                } else if let error = error {
                    Log.e(DetailViewController.TAG, error.localizedDescription)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    @IBAction func actionAdd() {
        guard let id = conversation?.id, let user = Auth.auth().currentUser?.uid else { return }
        let message = TextMessage(sender: user, timestamp: Timestamp.init(), data: Date().description)
        DatabaseManager.shared.messages.add(message: message, to: id)
    }
    
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row].data
        return cell
    }
    
    
}
