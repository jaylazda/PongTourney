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
            print("Game \(game.id) updated")
        }
        self.players = players
        print(players)
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
    
    // Removes a shot fromthe VC and adds a shot to the player total
    func playerDidShoot(player: Player) {
        if var gameData = gameData {
            gameData.shotsRemaining -= 1
            if player.id == players[0].id {
                gameData.p1TotalShots += 1
            } else if player.id == players[1].id {
                gameData.p2TotalShots += 1
            }
            firebase.gamesRef?.document(gameID).updateData([
                "shotsRemaining": gameData.shotsRemaining,
                "p1TotalShots": gameData.p1TotalShots,
                "p2TotalShots": gameData.p2TotalShots
            ])
        }
    }
    
    //set cup to true, add 1 shot to game, if last shot, switch turns
    func playerShotScored(cupHit: Int, player: Player) {
        if var gameData = gameData {
            if player.id == players[0].id {
                gameData.p1OnRedemption = false
                gameData.p1CupsHit += 1
                if gameData.p1CupsHit >= 6 { //P2 redemption
                    gameData.p2OnRedemption = true
                    gameData.p1Turn = false
                    gameData.shotsRemaining = 2
                } else {
                    gameData.score[0] += 1
                    gameData.p1CupsLeft[cupHit] = true
                }
                firebase.gamesRef?.document(gameID).updateData([
                    "p1CupsLeft": gameData.p1CupsLeft,
                    "p1CupsHit": gameData.p1CupsHit,
                    "p1OnRedemption": gameData.p1OnRedemption,
                    "p2OnRedemption": gameData.p2OnRedemption,
                    "p1Turn": gameData.p1Turn,
                    "shotsRemaining": gameData.shotsRemaining,
                    "score": gameData.score
                ])
            } else if player.id == players[1].id {
                gameData.p2OnRedemption = false
                gameData.p2CupsHit += 1
                if gameData.p2CupsHit >= 6 {
                    gameData.p1OnRedemption = true
                    gameData.p1Turn = true
                    gameData.shotsRemaining = 2
                } else {
                    gameData.score[1] += 1
                    gameData.p2CupsLeft[cupHit] = true
                }
                firebase.gamesRef?.document(gameID).updateData([
                    "p2CupsLeft": gameData.p2CupsLeft,
                    "p2CupsHit": gameData.p2CupsHit,
                    "p1OnRedemption": gameData.p1OnRedemption,
                    "p2OnRedemption": gameData.p2OnRedemption,
                    "p1Turn": gameData.p1Turn,
                    "shotsRemaining": gameData.shotsRemaining,
                    "score": gameData.score
                ])
            }
        }
    }
    
    func playerTurnFinished(player: Player) {
        if var gameData = gameData {
            gameData.shotsRemaining = 2
            if player.id == players[0].id {
                gameData.p1Turn = false
                if gameData.p1OnRedemption {
                    gameData.winner = players[1].id
                    gameData.isFinished = true 
                    gameData.p2CupsLeft = [true, true, true, true, true, true]
                    gameData.score[1] = 6
                }
            } else {
                gameData.p1Turn = true
                if gameData.p2OnRedemption {
                    gameData.winner = players[0].id
                    gameData.isFinished = true
                    gameData.p1CupsLeft = [true, true, true, true, true, true]
                    gameData.score[0] = 6
                }
            }
            firebase.gamesRef?.document(gameID).updateData([
                "shotsRemaining": gameData.shotsRemaining,
                "p1Turn": gameData.p1Turn,
                "winner": gameData.winner,
                "p1CupsLeft": gameData.p1CupsLeft,
                "p2CupsLeft": gameData.p2CupsLeft,
                "score": gameData.score
            ])
        }
    }
}
