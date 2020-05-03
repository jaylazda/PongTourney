//
//  JoinTournamentViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-30.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class JoinTournamentViewController: UIViewController {

    @IBOutlet weak var tourneyID: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    var numPlayers = 0
    var ref: DocumentReference? = nil
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.layer.cornerRadius = 25
        // Do any additional setup after loading the view.
    }
    
    @IBAction func joinClicked(_ sender: Any) {
        checkIfTourneyOpen()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let bracketVC = segue.destination as? BracketViewController else { return }
        bracketVC.numPlayers = Double(numPlayers)
        bracketVC.tourneyID = (tourneyID.text ?? "")
    }
    
    func checkIfTourneyOpen() {
        let tourneyRef = db.collection("tournament").document(tourneyID.text ?? "")
        tourneyRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.numPlayers = document.get("numPlayers") as! Int
                    print("From closure \(self.numPlayers)")
                    self.joinTournament()
                } else {
                    let alertController = UIAlertController(title: "Error", message: "Tournament does not exist.", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                     alertController.addAction(defaultAction)
                     self.present(alertController, animated: true, completion: nil)
                }
            }
    }
    
    func joinTournament() {
        let user = Auth.auth().currentUser?.uid ?? ""
        let playersRef = db.collection("users")
        let player = playersRef.document(user)
        let tourneyRef = db.collection("tournament").document(tourneyID.text ?? "")
        tourneyRef.updateData([
            "players": FieldValue.arrayUnion([player])
        ])
        self.performSegue(withIdentifier: "joinToBracket", sender: self)
    }

}
