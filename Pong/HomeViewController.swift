//
//  HomeViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-27.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class HomeViewController: UIViewController {

    @IBOutlet weak var setUpTourneyButton: UIButton!
    @IBOutlet weak var leaderboardsButton: UIButton!
    @IBOutlet weak var myStatsButton: UIButton!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    var allPlayers: [Player] = []
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTourneyButton.layer.cornerRadius = 25
        leaderboardsButton.layer.cornerRadius = 25
        myStatsButton.layer.cornerRadius = 25
        startGameButton.layer.cornerRadius = 25
        logoutButton.layer.cornerRadius = 25
        readDatabase(db)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: animated)
    }
    
    @IBAction func setUpTourneyClicked(_ sender: Any) {
        
    }
    
    @IBAction func leaderboardsClicked(_ sender: Any) {
        
    }
    @IBAction func myStatsClicked(_ sender: Any) {
        
    }
    
    @IBAction func startGameClicked(_ sender: Any) {
        
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        do {
               try Auth.auth().signOut()
           }
        catch let signOutError as NSError {
               print ("Error signing out: %@", signOutError)
           }
           
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let initial = storyboard.instantiateInitialViewController()
           UIApplication.shared.keyWindow?.rootViewController = initial
    }
    
    func readDatabase(_ db: Firestore) {
           db.collection("users").getDocuments() { (querySnapshot, err) in
               if let err = err {
                   print("Error getting documents: \(err)")
               } else {
                   for document in querySnapshot!.documents {
                    let result = Result {
                        try document.data(as: Player.self)
                    }
                    switch result {
                    case .success(let player):
                        if let player = player {
                            self.allPlayers.append(player)
                        } else {
                            //nil
                        }
                    case .failure(let error):
                        print("Error decoding player: \(error)")
                    }
                    
                    
                    
                    
//                       let data = document.data()
//                       let name = data["first"] as? String ?? ""
//                       let rank = data["rank"] as? Int
//                       let games = String(describing: data["games"])
//                       let wins = String(describing: data["wins"])
//                       let losses = String(describing: data["losses"])
//                       let shots = String(describing: data["total shots"])
//                       let shotsHit = String(describing: data["hit shots"])
//                       let shotsMissed = String(describing: data["missed shots"])
//                       let redemptions = String(describing: data["redemptions"])
//                    self.allPlayers.append(Player(name: name, rank: "\(rank ?? nil)", gamesPlayed: games, wins: wins, losses: losses, shots: shots, shotsHit: shotsHit, shotsMissed: shotsMissed, shotPercentage: "55%", redemptions: redemptions))
                   }
               }
           }
       }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let leaderboardVC = segue.destination as? LeaderboardsTableViewController else { return }
        leaderboardVC.allPlayers = self.allPlayers
    }
    

}
