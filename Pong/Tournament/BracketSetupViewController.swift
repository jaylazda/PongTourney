//
//  BracketSetupViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-28.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class BracketSetupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let players = [4, 8, 16, 32]
    var selectedPlayers = 4
    @IBOutlet weak var numPlayers: UIPickerView!
    @IBOutlet weak var goButton: UIButton!
    var ref: DocumentReference? = nil
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        goButton.layer.cornerRadius = 25
        numPlayers.delegate = self
        numPlayers.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return players.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(players[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPlayers = players[row]
    }

    @IBAction func goClicked(_ sender: Any) {
        addToDatabase()
        self.performSegue(withIdentifier: "goToBracket", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let bracketVC = segue.destination as? BracketViewController else { return }
        bracketVC.numPlayers = Double(selectedPlayers)
        bracketVC.tourneyID = (ref!.documentID)
    }
    
    func addToDatabase() {
        let host = Auth.auth().currentUser?.uid ?? ""
        let playersRef = db.collection("users")
        _ = playersRef.whereField("id", isEqualTo: host)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                }
        }
        ref = db.collection("tournament").addDocument(data: [
            "numPlayers": selectedPlayers,
            "gamesPerRound": 1,
            "host": playersRef.document(host),
            "currentGames": [],
            "players": [playersRef.document(host)],
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.ref!.documentID)")
            }
        }
        
        
    }
        
}
