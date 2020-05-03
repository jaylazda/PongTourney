//
//  SignUpViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-28.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordConfirm: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    var ref: DocumentReference? = nil
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupButton.layer.cornerRadius = 25
    }
    

    @IBAction func signupButtonClicked(_ sender: Any) {
        if password.text != passwordConfirm.text {
        let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
                }
        else{
        Auth.auth().createUser(withEmail: email.text!, password: password.text!){ (user, error) in
         if error == nil {
            self.addToDatabase()
            self.performSegue(withIdentifier: "signupToHome", sender: self)
                        }
         else{
           let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
           let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
               }
                    }
              }
    }
    
    //ADD CHECK TO MAKE SURE NO BLANK FIELDS
    func addToDatabase() {
        ref = db.collection("users").addDocument(data: [
            "id": Auth.auth().currentUser?.uid ?? "",
            "firstName": firstName.text ?? "",
            "lastName": lastName.text ?? "",
            "email": email.text ?? "",
            "games": 0,
            "wins": 0,
            "losses": 0,
            "shots": 0,
            "shotsMissed": 0,
            "shotsHit": 0,
            "shotPercentage": "0%",
            "redemptions": 0,
            "rank": 1
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.ref!.documentID)")
            }
        }

    }

}
