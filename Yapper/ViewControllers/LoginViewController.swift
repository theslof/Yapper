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
    private static let TAG = "LoginViewController"

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var submitButton: RoundedButton!
    @IBOutlet weak var signupButton: UIButton!

    var spinner: UIActivityIndicatorView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createAndSetupSpinner()
        spinner?.startAnimating()
        errorLabel.textColor = Theme.defaultTheme.error
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
        
        let auth = DatabaseManager.shared.auth
        guard let username = emailTextField.text,
            let password = passwordTextField.text else { return }
        auth.signIn(withEmail: username, password: password, completion: { (result, error) in
            self.submitButton.isEnabled = true
            self.spinner?.stopAnimating()
            
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .invalidEmail, .userNotFound, .wrongPassword:
                    self.showError("Incorrect username or password")
                case .userDisabled:
                    self.showError("User account disabled")
                default:
                    self.showError(error.localizedDescription)
                }
                Log.e(LoginViewController.TAG, error.localizedDescription)
            } else if result != nil {
                self.performSegue(withIdentifier: "segueShowMainView", sender: self)
            }
        })
    }
}
