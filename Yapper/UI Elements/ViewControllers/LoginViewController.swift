//
//  LoginViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-09.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: ThemedViewController {
    private static let TAG = "LoginViewController"

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var submitButton: RoundedButton!
    @IBOutlet weak var signupButton: UIButton!

    var spinner: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard let window = UIApplication.shared.delegate?.window else { return }
            var vc = window!.rootViewController
            if(vc is UINavigationController){
                vc = (vc as! UINavigationController).visibleViewController
            }
            
            var newViewController: UIViewController?
            
            if user == nil, !(vc is LoginViewController) {
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                newViewController = storyboard.instantiateViewController(withIdentifier: "loginViewController")
            } else if user != nil, vc is LoginViewController {
                let _ = DatabaseManager.shared
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                newViewController = storyboard.instantiateViewController(withIdentifier: "mainViewController")
            }
            
            if let newViewController = newViewController, let window = window {
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = newViewController
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createAndSetupSpinner()
        errorLabel.textColor = Theme.currentTheme.error
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let auth = Auth.auth()

        if auth.currentUser == nil {
            self.spinner?.stopAnimating()
        }
        
        self.view.backgroundColor = Theme.currentTheme.background
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
                    self.showError(NSLocalizedString("incorrectUserPassword", comment: "Incorrect username or password"))
                case .userDisabled:
                    self.showError(NSLocalizedString("userDisabled", comment: "User account disabled"))
                default:
                    self.showError(error.localizedDescription)
                }
                Log.e(LoginViewController.TAG, error.localizedDescription)
            }
        })
    }
}
