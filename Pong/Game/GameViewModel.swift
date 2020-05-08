//
//  GameViewModel.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-05-07.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import Foundation
import Firebase

class GameViewModel {
    
    var firebase = FirebaseService.shared
    var gameID = ""
    var players: [Player] = []
    var player1Cups = [false, false, false, false, false, false]
    var player2Cups = [false, false, false, false, false, false]
    var gameData: Game? = nil
    
    init(_ gameID: String, _ players: [Player]) {
        self.gameID = gameID
        fetchGameData(gameID) { game in
            self.gameData = game
            print("Game \(game.id) initialized")
        }
        self.players = players
        print(players)
//        for playerID in playerIDs {
//            fetchPlayerData(playerID) { player in
//                self.players.append(player)
//                print(player)
//                print("Player \(player.firstName) initialized")
//            }
//        }
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
    
    func fetchPlayerData(_ playerID: String, queue: DispatchQueue = .main, completionHandler: @escaping (_ player: Player) -> Void) {
        firebase.playersRef?.whereField("id", isEqualTo: playerID)
            .getDocuments() { (querySnapshot, err) in
                var player = Player()
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                     let result = Result {
                         try document.data(as: Player.self)
                     }
                     switch result {
                     case .success(let playerData):
                         if let playerData = playerData {
                             player = playerData
                         } else {
                             print("Player is empty")
                         }
                     case .failure(let error):
                         print("Error decoding player: \(error)")
                        }
                    }
                }
                    queue.async {
                        completionHandler(player)
                    }
            }
    }
    
    func playerShotMissed(player: Player) {
        gameData?.shotsRemaining -= 1
        if player.id == players[0].id {
            gameData?.p1TotalShots += 1
            if (gameData?.shotsRemaining) == 0 {
                gameData?.shotsRemaining = 2
                gameData?.p1Turn = false
            }
        } else if player.id == players[1].id {
            gameData?.p2TotalShots += 1
            if (gameData?.shotsRemaining) == 0 {
                gameData?.shotsRemaining = 2
                gameData?.p1Turn = true
            }
        }
    }
    
    //set cup to true, add 1 shot to game, if last shot, switch turns
    func playerShotScored(cupHit: Int, player: Player) {
        gameData?.shotsRemaining -= 1
        if player.id == players[0].id {
            gameData?.p1TotalShots += 1
            gameData?.p1CupsLeft[cupHit] = true
            if (gameData?.shotsRemaining) == 0 {
                gameData?.shotsRemaining = 2
                gameData?.p1Turn = false
            }
        } else if player.id == players[1].id {
            gameData?.p2TotalShots += 1
            gameData?.p2CupsLeft[cupHit] = true
            if (gameData?.shotsRemaining) == 0 {
                gameData?.shotsRemaining = 2
                gameData?.p1Turn = true
            }
        }
    }
}
