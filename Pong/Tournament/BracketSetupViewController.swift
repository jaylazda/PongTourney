//
//  BracketSetupViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-28.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit
import Firebase

class BracketSetupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let players = [4, 8, 16, 32]
    var selectedPlayers = 4
    @IBOutlet weak var numPlayers: UIPickerView!
    @IBOutlet weak var goButton: UIButton!
    let firebase = FirebaseService.shared
    var games: [Game] = []
    let defaults = UserDefaults()
    var gameRefs: [DocumentReference] = []
    
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
        //initializeGames()
        createTourneyWithHost()
        self.performSegue(withIdentifier: "goToBracket", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let bracketVC = segue.destination as? BracketViewController else { return }
        let tourneyID = firebase.docRef?.documentID ?? ""
        let user = firebase.authentication?.currentUser?.uid ?? ""
        bracketVC.numPlayers = Double(selectedPlayers)
        bracketVC.tourneyID = (tourneyID)
        defaults.set(tourneyID, forKey: user)
    }
    
    func createTourneyWithHost() {
        let host = firebase.authentication?.currentUser?.uid ?? ""
        for i in 0 ..< selectedPlayers/2 {
            games.append(Game(id: "\(i)"))
        }
        for game in games {
            let result = Result {
                firebase.docRef = try firebase.gamesRef?.addDocument(from: game)
            }
            switch result {
            case .success:
                gameRefs.append(firebase.docRef!)
                print("Game successfully added")
            case .failure(let error):
                print("Error encoding game: \(error)")
            }
        }
        firebase.docRef = firebase.tournamentsRef?.addDocument(data: [
            "numPlayers": selectedPlayers,
            "registeredPlayers": 1,
            "gamesPerRound": 1,
            "host": firebase.playersRef?.document(host) ?? "",
            "games": gameRefs,
            "players": [firebase.playersRef?.document(host)],
            "tourneyFull": false
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(String(describing: self.firebase.docRef?.documentID))")
            }
        }
    }
        
}
