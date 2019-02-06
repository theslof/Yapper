//
//  SignupViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-09.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignupViewController: ThemedViewController {
    private static let TAG = "SignupViewController"

    @IBOutlet weak var displaynameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var submitButton: RoundedButton!
    @IBOutlet weak var signupButton: RoundedButton!
    
    var spinner: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createAndSetupSpinner()
        errorLabel.textColor = Theme.defaultTheme.error
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let auth = Auth.auth()
        
        if auth.currentUser != nil {
            self.dismiss(animated: true, completion: nil)
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
        spinner.backgroundColor = Theme.currentTheme.background.withAlphaComponent(0.5)
        spinner.style = .whiteLarge
        spinner.color = UIColor.black
        spinner.isOpaque = true
        
        NSLayoutConstraint.activate([
            spinner.topAnchor.constraint(equalTo: view.topAnchor),
            spinner.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            spinner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spinner.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
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
    
    @IBAction func actionSubmit(_ sender: UIButton) {
        self.hideError()
        self.submitButton.isEnabled = false
        self.spinner?.startAnimating()
        
        guard
            let username = emailTextField.text, username != "",
            let password = passwordTextField.text, password != "",
            let displayname = displaynameTextField.text, displayname != ""
        else {
            self.showError("Please fill in all fields!")
            self.submitButton.isEnabled = true
            self.spinner?.stopAnimating()
            return
        }
        DatabaseManager.shared.auth.signUp(email: username, password: password, displayName: displayname) { (result, error) in
            self.submitButton.isEnabled = true
            self.spinner?.stopAnimating()
            
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .invalidEmail:
                    self.showError("Email was not acceped as a valid format")
                case .emailAlreadyInUse:
                    self.showError("User already exists")
                case .weakPassword:
                    self.showError("Please create a stronger password")
                default:
                    self.showError(error.localizedDescription)
                }
                Log.e(SignupViewController.TAG, error.localizedDescription)
            } else if result != nil {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func actionCancel(_ sender: RoundedButton) {
        dismiss(animated: true, completion: nil)
    }
}
