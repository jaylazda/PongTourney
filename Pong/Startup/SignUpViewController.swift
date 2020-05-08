//
//  SignUpViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-28.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirm: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupButton.layer.cornerRadius = 25
    }
    
    @IBAction func signupButtonClicked(_ sender: Any) {
        //Checks if there are empty fields and if passwords match
        if let email = emailField.text, let firstName = firstNameField.text, let lastName = lastNameField.text, let password = passwordField.text, !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !password.isEmpty {
            if password != passwordConfirm.text {
                let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                FirebaseService.shared.addNewUser(email, password, firstName, lastName, view: self)
            }
        } else {
            let alertController = UIAlertController(title: "Empty Field", message: "Please fill in all fields.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }

    }

}
