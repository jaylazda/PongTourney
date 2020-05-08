//
//  LoginViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-28.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 25
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        if let email = emailField.text, let password = passwordField.text {
            FirebaseService.shared.signIn(email, password, view: self)
        }
    }
    
}
