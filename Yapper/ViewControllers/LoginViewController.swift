//
//  LoginViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-09.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    var spinner: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createAndSetupSpinner()
        spinner?.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let auth = Auth.auth()
        
        if auth.currentUser != nil {
            self.performSegue(withIdentifier: "segueShowMainView", sender: self)
        } else {
            self.spinner?.stopAnimating()
        }
    }
    
    private func createAndSetupSpinner() {
        spinner = UIActivityIndicatorView(frame: .zero)
        
        guard let spinner = spinner else { return }
        view.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        
        NSLayoutConstraint.activate([
            spinner.topAnchor.constraint(equalTo: view.topAnchor),
            spinner.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            spinner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spinner.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }
    
    @IBAction func actionSubmit(_ sender: UIButton) {
        self.hideError()
        self.submitButton.isEnabled = false
        self.spinner?.startAnimating()
        
        let auth = Auth.auth()
        guard let username = usernameTextField.text,
            let password = passwordTextField.text else { return }
        auth.signIn(withEmail: username, password: password, completion: { (result, error) in
            self.submitButton.isEnabled = true
            self.spinner?.stopAnimating()
            
            if let errCode = error?._code, let errorCode = AuthErrorCode(rawValue: errCode) {
                switch errorCode {
                case .invalidEmail, .userNotFound, .wrongPassword:
                    self.showError("Incorrect username or password")
                case .userDisabled:
                    self.showError("User account disabled")
                default:
                    self.showError(error!.localizedDescription)
                }
            } else if result != nil {
                self.performSegue(withIdentifier: "segueShowMainView", sender: self)
            }
        })
    }
    
    func showError(_ message: String) {
        UIView.animate(withDuration: 0.35, animations: {
            self.errorLabel.text = message
            self.errorLabel.isHidden = false
        })
    }
    
    func hideError() {
        UIView.animate(withDuration: 0.35, animations: {
            self.errorLabel.isHidden = true
        })
    }
}
