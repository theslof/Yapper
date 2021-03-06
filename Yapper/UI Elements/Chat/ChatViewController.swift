//
//  DetailViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-09.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: ThemedViewController {
    private static let TAG = "DetailViewController"

    @IBOutlet weak var buttonAttach: RoundedButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var buttonSend: RoundedButton!
    @IBOutlet weak var tableView: ConversationTableView!
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewNewMessages: UIView!
    @IBOutlet weak var labelNewMessages: UILabel!
    @IBOutlet weak var constraintTopNewMessages: NSLayoutConstraint!
    
    var messages: [Message] = []
    var listener: ListenerRegistration?
    private var atBottom: Bool = false
    private var firstView: Bool = true
    private var picker: UIImagePickerController?
    
    var detailItem: Conversation? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Theme.currentTheme.background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.viewNewMessages.backgroundColor = Theme.currentTheme.backgroundText
        self.viewNewMessages.layer.masksToBounds = false
        self.viewNewMessages.layer.shadowColor = Theme.currentTheme.text.cgColor
        self.viewNewMessages.layer.shadowOpacity = 0.25
        self.viewNewMessages.layer.shadowRadius = 1.5
        self.viewNewMessages.layer.shadowOffset = CGSize(width: 0, height: 1.5)

//        self.labelNewMessages.textColor = Theme.currentTheme.text
        self.constraintTopNewMessages.constant = -self.viewNewMessages.frame.height
        
        if detailItem?.members.count == 2,
            let user = Auth.auth().currentUser?.uid,
            let other = detailItem?.members.first(where: { $0 != user }) {
            DatabaseManager.shared.users.getUser(uid: other) { (user, error) in
                if let user = user {
                    self.title = user.displayName
                }
            }
        } else if let item = detailItem {
            self.title = String(format: NSLocalizedString("numberParticipants", comment: "%d participants"), item.members.count)
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
            Log.d(ChatViewController.TAG, "Messages updated! Found \(messages.count) messages!")
            
            // Parse messages and sort by timestamp
            self.messages = messages
                .compactMap { Conversation.parse(message: $0.data()) }
                .filter { (message) -> Bool in
                    !(DatabaseManager.shared.users.getFriendlist()[message.sender]?.isIgnored ?? false)
                }
                .sorted(by: { $0.timestamp.dateValue() < $1.timestamp.dateValue() })
            self.tableView.reloadData()
            
            if tableView.contentSize.height < tableView.frame.height, let cid = detailItem?.id {
                SaveData.shared.update(lastUpdated: Timestamp(), forConversation: cid)
            }
            
            if let last = self.messages.last,
                let user = Auth.auth().currentUser?.uid,
                last.sender == user {
                // If the last message was sent by the user we just scroll to the bottom
                self.scrollTo(row: self.messages.count, animated: true)
            } else {
                // Otherwise we find out how many new messages there are
                let firstIndex = updateNewMessages()
                
                // and scroll to the last seen message if this is the first time after loading the view
                if firstView {
                    self.scrollTo(row: firstIndex, animated: false)
                }
                firstView = false
            }
        } else if let error = error {
            Log.e(ChatViewController.TAG, error.localizedDescription)
        }
    }
    
    func updateNewMessages() -> Int {
        var newMessages = 0
        var firstNewMessage = 0
        if let cid = detailItem?.id,
            let lastUpdated = SaveData.shared.getLastUpdated(forConversation: cid) {
            firstNewMessage = self.messages.firstIndex { lastUpdated.dateValue() <= $0.timestamp.dateValue() } ?? messages.count
            newMessages = messages.count - firstNewMessage
        }
        
        if newMessages > 0 {
            labelNewMessages.text = String(format: NSLocalizedString("numberNewMessages", comment: "%d new messages!"), newMessages)
            labelNewMessages.isHidden = false
            UIView.animate(withDuration: 0.75) {
                self.constraintTopNewMessages.constant = 0
            }
        } else {
            labelNewMessages.text = NSLocalizedString("noNewMessages", comment: "No new messages!")
            UIView.animate(withDuration: 0.75, animations: {
                self.constraintTopNewMessages.constant = -self.viewNewMessages.frame.height
            }, completion: { done in
                self.labelNewMessages.isHidden = done
            })
        }
        return firstNewMessage
    }
    
    @IBAction func actionGoToLast() {
        scrollTo(row: messages.count, animated: true)
    }
    
    func scrollTo(row: Int, animated: Bool) {
        let row = row >= messages.count ? messages.count - 1 : row
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
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userPickerNavigationController") as? UINavigationController, let picker = controller.viewControllers.first as? UserPickerViewController {
            picker.delegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionAttach() {
        let alert = UIAlertController(title:
            NSLocalizedString("titleSendImage", comment: "Send image"), message:
            NSLocalizedString("messageSelectImageSource", comment: "Select an image source"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("url", comment: "URL"), style: .default, handler: attachImageURL))
        alert.addAction(UIAlertAction(title: NSLocalizedString("photoLibrary", comment: "Photo Library"), style: .default, handler: attachImageFromLibrary))
        alert.addAction(UIAlertAction(title: NSLocalizedString("camera", comment: "Camera"), style: .default, handler: attachImageFromCamera))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func attachImageFromLibrary(_ action: UIAlertAction) {
        picker = UIImagePickerController()
        picker!.delegate = self
        picker!.allowsEditing = false
        picker!.sourceType = .photoLibrary
        present(picker!, animated: true, completion: nil)
    }
    
    private func attachImageFromCamera(_ action: UIAlertAction) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker = UIImagePickerController()
            picker!.delegate = self
            picker!.allowsEditing = false
            picker!.sourceType = .camera
            picker!.cameraCaptureMode = .photo
            picker!.modalPresentationStyle = .popover
            
            present(picker!, animated: true, completion: nil)

            picker!.popoverPresentationController?.sourceRect = buttonAttach.frame
        } else {
            // Camera not available
            Log.e(ChatViewController.TAG, "Missing camera, sorry :(")
        }
    }
    
    private func attachImageURL(_ action: UIAlertAction) {
        var text: UITextField?
        let alert = UIAlertController(title: NSLocalizedString("titleSendImage", comment: "Send image"), message: NSLocalizedString("messageInputImageURL", comment: "Input an image URL"), preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            text = textField
            textField.placeholder = NSLocalizedString("imageURL", comment: "Image URL")
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("send", comment: "Send"), style: .default, handler: { (action) in
            guard
                let textField = text,
                let urlString = textField.text,
                !urlString.isEmpty,
                let url = URL(string: urlString) else {
                    Log.e(ChatViewController.TAG, "Could not read a URL from alert input")
                    return }
            self.sendImage(url: url)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func sendImage(url: URL) {
        guard
            let id = self.detailItem?.id,
            let user = Auth.auth().currentUser?.uid else {
                Log.e(ChatViewController.TAG, "Could not send image")
                return }
        let message = ImageMessage(sender: user, timestamp: Timestamp.init(), data: url.absoluteString)
        DatabaseManager.shared.messages.add(message: message, to: id)
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        var cell: ChatTableViewMessageCell
        
        switch message {
        case is TextMessage:
            cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as? ChatTableViewTextMessageCell ?? ChatTableViewTextMessageCell()
            cell.set(message: message)
        case is ImageMessage:
            let _cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as? ChatTableViewImageMessageCell ?? ChatTableViewImageMessageCell()
            _cell.set(message: message)
            
            if let view = _cell.view {
                let tap = UITapGestureRecognizer(target: self, action: #selector(actionShowFullImage(_:)))
                view.addGestureRecognizer(tap)
            }
            
            cell = _cell
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatTableViewMessageCell ?? ChatTableViewMessageCell()
            cell.set(message: message)
        }

        if let profile = cell.getProfileImageView() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
            profile.addGestureRecognizer(tap)
        }
        return cell
    }

    @objc func showProfile(_ sender: UITapGestureRecognizer? = nil) {
        if let profileImage = sender?.view as? ProfileImage,
            let uid = profileImage.uid,
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileViewController") as? ProfileViewController {
            controller.uid = uid
            self.present(controller, animated: true, completion: nil)
        } else {
            Log.e(ChatViewController.TAG, "Tapped on profile image, failed to parse")
        }
    }

    @objc func actionShowFullImage(_ sender: UITapGestureRecognizer? = nil) {
        if let message = sender?.view as? MessageImageView,
            let data = message.message?.data,
            let url = URL(string: data),
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageViewController") as? ImageViewController {
            controller.imageURL = url
            self.present(controller, animated: true, completion: nil)
        } else {
            Log.e(ChatViewController.TAG, "Tapped on message, failed to parse")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        atBottom = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height < 10
        if atBottom {
            if let cid = detailItem?.id {
                SaveData.shared.update(lastUpdated: Timestamp(), forConversation: cid)
            }
            _ = updateNewMessages()
        }
    }
}

extension ChatViewController: UserPickerDelegate {
    func userPicker(_ userPicker: UserPickerViewController, didFinishPickingUsersWithUsers users: [String]) {
        guard let id = detailItem?.id else { return }
        DatabaseManager.shared.messages.addUsersToConversation(users: users, conversation: id)
    }
}

extension ChatViewController: UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.picker?.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        StorageManager.shared.uploadImage(image) { (url, error) in
            if let url = url {
                Log.d(ChatViewController.TAG, "Uploaded image, attempting to send message")
                self.sendImage(url: url)
            } else if let error = error {
                Log.e(ChatViewController.TAG, error.localizedDescription)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        Log.d(ChatViewController.TAG, "Cancelled the picker!")
        self.picker?.dismiss(animated: true, completion: nil)
    }
    
}
