//
//  WaitingRoomViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-05-25.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit

class WaitingRoomViewController: UIViewController {

    @IBOutlet weak var gameIDLabel: UILabel!
    @IBOutlet weak var waitingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var gameID = ""
    var player1 = Player()
    var player2 = Player()
    var firebase = FirebaseService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameIDLabel.text = gameID
        activityIndicator.startAnimating()
        fetchGameData(gameID) { game in
            self.getPlayerData(game.player1) { player in
                self.player1 = player
                if game.player2 != "" {
                    self.getPlayerData(game.player2) { player in
                        self.player2 = player
                        self.performSegue(withIdentifier: "goToGame", sender: self)
                    }
                }
            }
        }
    }
    
    func fetchGameData(_ gameID: String, queue: DispatchQueue = .main, completionHandler: @escaping (_ gameData: Game) -> Void) {
        firebase.gamesRef?.document(gameID)
            .addSnapshotListener() { (documentSnapshot, error) in
                var gameData = Game()
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                let result = Result {
                    try document.data(as: Game.self)
                }
                switch result {
                case .success(let game):
                    if let game = game {
                        gameData = game
                    } else {
                        print("Game is empty")
                    }
                case .failure(let error):
                    print("Error decoding game: \(error)")
                }
                queue.async {
                    completionHandler(gameData)
                }
            }
    }
    
    func getPlayerData(_ playerID: String, completionHandler: @escaping (_ playerData: Player) -> Void) {
        var playerData = Player()
        firebase.playersRef?.whereField("id", isEqualTo: playerID)
            .getDocuments() { querySnapshot, error in
                    if let err = error {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let result = Result {
                                try document.data(as: Player.self)
                            }
                            switch result {
                            case .success(let player):
                                if let player = player {
                                    playerData = player
                                    print("Received player data from server.")
                                } else {
                                    print("Player is empty")
                                }
                            case .failure(let error):
                                print("Error decoding player: \(error)")
                            }
                        }
                        completionHandler(playerData)
                }
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let gameVC = segue.destination as? GameViewController else { return }
        gameVC.players = [player1, player2]
        gameVC.player1Name = player1.firstName
        gameVC.player2Name = player2.firstName
        gameVC.gameID = gameID
    }

}
