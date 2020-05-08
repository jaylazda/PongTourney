//
//  StartPageViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-28.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit

class StartPageViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 25
        signupButton.layer.cornerRadius = 25
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if FirebaseService.shared.authentication?.currentUser != nil {
            self.performSegue(withIdentifier: "loggedIn", sender: nil)
        }
    }

}
