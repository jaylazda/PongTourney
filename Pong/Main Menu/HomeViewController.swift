//
//  HomeViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-27.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var setUpTourneyButton: UIButton!
    @IBOutlet weak var leaderboardsButton: UIButton!
    @IBOutlet weak var myStatsButton: UIButton!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    var allPlayers: [Player] = []
    let defaults = UserDefaults()
    let user = FirebaseService.shared.authentication?.currentUser?.uid ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTourneyButton.layer.cornerRadius = 25
        leaderboardsButton.layer.cornerRadius = 25
        myStatsButton.layer.cornerRadius = 25
        startGameButton.layer.cornerRadius = 25
        logoutButton.layer.cornerRadius = 25
        getAllPlayers()
        //defaults.removeObject(forKey: user)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: animated)
    }
    
    @IBAction func tournamentClicked(_ sender: Any) {
        if ((defaults.string(forKey: user)) != nil) {
            self.performSegue(withIdentifier: "goToCurrentTourney", sender: self)
        } else {
            self.performSegue(withIdentifier: "goToNewTournament", sender: self)
        }
    }
    
    @IBAction func leaderboardsClicked(_ sender: Any) {
        
    }
    @IBAction func myStatsClicked(_ sender: Any) {
        
    }
    
    @IBAction func startGameClicked(_ sender: Any) {
        
    }
    
    @IBAction override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        do {
            try FirebaseService.shared.authentication?.signOut()
        } catch let signOutError as NSError {
               print ("Error signing out: %@", signOutError)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }
    // TODO: CHECK IF ALREADY IN TOURNAMENT -> if yes -> go to tournament goToCurrentTourney
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let leaderboardVC = segue.destination as? LeaderboardsTableViewController else {
            guard let tourneyVC = segue.destination as? BracketViewController else {
                return
            }
            tourneyVC.tourneyID = defaults.string(forKey: user)!
            tourneyVC.numPlayers = defaults.double(forKey: "numPlayers")
            return
        }
        leaderboardVC.allPlayers = self.allPlayers
    }
    
    func getAllPlayers() {
        FirebaseService.shared.playersRef?.getDocuments() { (querySnapshot, err) in
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
                }
            }
        }
    }

}

/*
 create tournament with 16 players
 -> 8 Games are initialized
 -> each game has 2 players, each game is a section
 -> players are loaded into games
 */
