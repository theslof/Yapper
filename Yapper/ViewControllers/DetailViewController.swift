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

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var buttonSend: RoundedButton!
    @IBOutlet weak var tableView: ConversationTableView!
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    
    var conversation: Conversation?
    var messages: [Message] = []
    var listener: ListenerRegistration?
    private var atBottom: Bool = false
    private var firstView: Bool = true

    func configureView() {
        // Update the user interface for the detail item.
        if let listener = listener {
            listener.remove()
        }
        if let conversation = conversation?.id {
            listener = DatabaseManager.shared.messages.getMessages(for: conversation) { snapshot, error in
                if let messages = snapshot?.documents {
                    Log.d(DetailViewController.TAG, "Messages updated! Found \(messages.count) messages!")
                    self.messages = messages
                        .compactMap { Conversation.parse(message: $0.data()) }
                        .sorted(by: { $0.timestamp.dateValue() < $1.timestamp.dateValue() })
                    self.tableView.reloadData()
                    if let last = self.messages.last?.sender, let user = Auth.auth().currentUser?.uid, last == user || self.atBottom || self.firstView {
                        self.tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                        self.firstView = false
                    }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }

    var detailItem: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        inputViewBottomConstraint.constant = frame.cgRectValue.height
        self.tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
        view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        inputViewBottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    @IBAction func actionSend() {
        inputTextField.resignFirstResponder()
        guard
            let id = conversation?.id,
            let user = Auth.auth().currentUser?.uid,
            let text = inputTextField.text,
            !text.isEmpty else { return }
        let message = TextMessage(sender: user, timestamp: Timestamp(), data: text)
        DatabaseManager.shared.messages.add(message: message, to: id)
        inputTextField.text = ""
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatTableViewCell ?? ChatTableViewCell()
        cell.set(message: messages[indexPath.row])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        atBottom = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height < 100
    }
}
