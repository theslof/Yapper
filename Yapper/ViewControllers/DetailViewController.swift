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

    @IBOutlet weak var buttonAttach: RoundedButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var buttonSend: RoundedButton!
    @IBOutlet weak var tableView: ConversationTableView!
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    
    var messages: [Message] = []
    var listener: ListenerRegistration?
    private var atBottom: Bool = false
    private var firstView: Bool = true
    var detailItem: Conversation? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.view.backgroundColor = Theme.currentTheme.background
        if detailItem?.members.count == 2,
            let user = Auth.auth().currentUser?.uid,
            let other = detailItem?.members.first(where: { $0 != user }) {
            DatabaseManager.shared.users.getUser(uid: other) { (user, error) in
                if let user = user {
                    self.title = user.displayName
                }
            }
        } else if let item = detailItem {
            self.title = "\(item.members.count) participants"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helpers
    
    func configureView() {
        // Update the user interface for the detail item.
        if let listener = listener {
            listener.remove()
        }
        if let conversation = detailItem?.id {
            listener = DatabaseManager.shared.messages
                .getMessages(for: conversation, listener: onNewMessages)
        }
    }
    
    func onNewMessages(snapshot: QuerySnapshot?, error: Error?) {
        if let messages = snapshot?.documents {
            Log.d(DetailViewController.TAG, "Messages updated! Found \(messages.count) messages!")
            
            // Parse messages and sort by timestamp
            self.messages = messages
                .compactMap { Conversation.parse(message: $0.data()) }
                .sorted(by: { $0.timestamp.dateValue() < $1.timestamp.dateValue() })
            self.tableView.reloadData()
            
            if
                let last = self.messages.last?.sender,
                let user = Auth.auth().currentUser?.uid,
                last == user || // If the user posted the newest message
                    self.atBottom || // or if the user is viewing the bottom of the convo
                    self.firstView { // or if this is the fist time data is loaded:
                // Scroll to the last message of the conversation
                self.scrollTo(row: self.messages.count - 1, animated: !self.firstView)
                self.firstView = false
            }
        } else if let error = error {
            Log.e(DetailViewController.TAG, error.localizedDescription)
        }
    }
    
    func scrollTo(row: Int, animated: Bool) {
        if row < 1 {
            return
        }
        let indexPath = IndexPath(row: row, section: 0)
        self.tableView.selectRow(at: indexPath, animated: animated, scrollPosition: .bottom)
    }
    
    // MARK: - Events

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        inputViewBottomConstraint.constant = frame.cgRectValue.height
        self.scrollTo(row: messages.count - 1, animated: true)
        view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        inputViewBottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    @IBAction func actionSend() {
        inputTextField.resignFirstResponder()
        guard
            let id = detailItem?.id,
            let user = Auth.auth().currentUser?.uid,
            let text = inputTextField.text,
            !text.isEmpty else { return }
        let message = TextMessage(sender: user, timestamp: Timestamp(), data: text)
        DatabaseManager.shared.messages.add(message: message, to: id)
        inputTextField.text = ""
    }
    
    @IBAction func actionAdd() {
        guard let id = detailItem?.id, let user = Auth.auth().currentUser?.uid else { return }
        let message = TextMessage(sender: user, timestamp: Timestamp.init(), data: Date().description)
        DatabaseManager.shared.messages.add(message: message, to: id)
    }
    
    @IBAction func actionAttach() {
        Log.d(DetailViewController.TAG, "Attempted to send an object message, not yet implemented")
        guard let id = detailItem?.id, let user = Auth.auth().currentUser?.uid else { return }
        let message = ImageMessage(sender: user, timestamp: Timestamp.init(), data: "https://upload.wikimedia.org/wikipedia/commons/0/0c/Cow_female_black_white.jpg")
        DatabaseManager.shared.messages.add(message: message, to: id)
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatTableViewCell ?? ChatTableViewCell()
        cell.set(message: messages[indexPath.row])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        atBottom = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height < 100
    }
}
