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
    var playersRegistered = 0
    let firebase = FirebaseService.shared
    var tourneyNowFull = false
    let defaults = UserDefaults()
    
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
        firebase.docRef = firebase.tournamentsRef?.document(tourneyID.text ?? "")
        firebase.docRef?.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.numPlayers = document.get("numPlayers") as! Int
                    self.playersRegistered = document.get("registeredPlayers") as! Int
                    self.tourneyNowFull = document.get("tourneyFull") as! Bool
                    if self.tourneyNowFull {
                        let alertController = UIAlertController(title: "Error", message: "Tournament is full.", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.playersRegistered += 1
                        if self.playersRegistered == self.numPlayers {
                            self.tourneyNowFull = true
                        }
                        self.joinTournament()
                    }
                } else {
                    let alertController = UIAlertController(title: "Error", message: "Tournament does not exist.", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                     alertController.addAction(defaultAction)
                     self.present(alertController, animated: true, completion: nil)
                }
            }
    }
    
    func joinTournament() {
        let user = firebase.authentication?.currentUser?.uid ?? ""
        let player = firebase.playersRef?.document(user)
        firebase.docRef = firebase.tournamentsRef?.document(tourneyID.text ?? "")
        firebase.docRef?.updateData([
            "players": FieldValue.arrayUnion([player]),
            "registeredPlayers": playersRegistered,
            "tourneyFull": tourneyNowFull
        ])
        defaults.set(tourneyID.text, forKey: user)
        self.performSegue(withIdentifier: "joinToBracket", sender: self)
    }

}
