//
//  MoreViewController.swift
//  PhotoMap
//
//  Created by Kiryl Harbachonak on 10/9/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit
import Firebase

class MoreViewController: UIViewController {
    
    var currentUser: User?

    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var signOutButton: UIButton!
    
    @IBAction private func signOutPressed(_ sender: UIButton) {
        guard let user = currentUser else { return }
        Database.database().reference(withPath: "online/\(user.uid)").removeValue { error, _ in
          if let error = error {
            print("Removing online failed: \(error.localizedDescription)")
            return
          }
          do {
            try Auth.auth().signOut()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = LoginViewController()
            self.dismiss(animated: true, completion: nil)
          } catch (let error) {
            print("Auth sign out failed: \(error)")
          }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailLabel.text = currentUser?.email
        signOutButton.layer.cornerRadius = 6
    }
}
