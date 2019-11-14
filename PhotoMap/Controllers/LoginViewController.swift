//
//  LoginViewController.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 11/2/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet private weak var emailTextField: UITextField!
    
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signInButton: UIButton!
    
    @IBAction private func signInPressed(_ sender: UIButton) {
        
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            email.count > 6,
            password.count > 6
        else {
            let errorAction = UIAlertController(
                title: "Error",
                message: "Input data is incorrect, please try again",
                preferredStyle: .alert
            )
            errorAction.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default
                )
            )
            present(errorAction, animated: true)
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(
                    title: "Sign In Failed",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Register",
            message: "Please, register",
            preferredStyle: .alert
        )
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let email = alert.textFields![0].text!
            let password = alert.textFields![1].text!
            
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] user, error in
                if error != nil {
                    let registrationFailedAlert = UIAlertController(
                        title: "Error",
                        message: error?.localizedDescription,
                        preferredStyle: .alert
                    )
                    registrationFailedAlert.addAction(
                        UIAlertAction(
                            title: "Try again", style: .cancel
                        ) { [weak self] _ in
                            self?.present(alert, animated: true)
                        }
                    )
                    self?.present(registrationFailedAlert, animated: true)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField { textEmail in
          textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
          textPassword.isSecureTextEntry = true
          textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.annotations.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.layer.cornerRadius = 6
        passwordTextField.isSecureTextEntry = true
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if user != nil {
                guard let self = self else { return }
                Coordinator.showMainApplication(from: self)
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
    @IBAction private func hideKeyboard(_ sender: Any) {
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
}
