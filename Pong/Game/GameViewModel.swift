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
            if gameData.shotsRemaining == 0 || gameData.shotsRemaining == 1 {
                gameData.shotHit[gameData.shotsRemaining] = true
            }
            if player.id == players[0].id {
                if gameData.p1OnRedemption {
                    players[0].redemptions += 1
                    gameData.p1Turn = false
                    gameData.shotsRemaining = 2
                    gameData.p1OnRedemption = false
                    gameData.shotHit = [false, false]
                } else {
                    gameData.p1CupsHit += 1
                    if gameData.p1CupsHit >= 6 {
                        gameData.p2OnRedemption = true
                        gameData.p1Turn = false
                        gameData.shotsRemaining = 2
                        gameData.shotHit = [false, false]
                    } else {
                        gameData.score[0] += 1
                        gameData.p1CupsLeft[cupHit] = true
                        if gameData.shotHit[0] && gameData.shotHit[1] {
                            gameData.p1Turn = true
                            gameData.shotsRemaining = 2
                        }
                    }
                }
                firebase.gamesRef?.document(gameID).updateData([
                    "p1CupsLeft": gameData.p1CupsLeft,
                    "p1CupsHit": gameData.p1CupsHit,
                    "p1OnRedemption": gameData.p1OnRedemption,
                    "p2OnRedemption": gameData.p2OnRedemption,
                    "p1Turn": gameData.p1Turn,
                    "shotHit": gameData.shotHit,
                    "shotsRemaining": gameData.shotsRemaining,
                    "score": gameData.score
                ])
            } else if player.id == players[1].id {
                if gameData.p2OnRedemption {
                    players[1].redemptions += 1
                    gameData.p1Turn = true
                    gameData.shotsRemaining = 2
                    gameData.p2OnRedemption = false
                    gameData.shotHit = [false, false]
                } else {
                    gameData.p2CupsHit += 1
                    if gameData.p2CupsHit >= 6 {
                        gameData.p1OnRedemption = true
                        gameData.p1Turn = true
                        gameData.shotsRemaining = 2
                         gameData.shotHit = [false, false]
                    } else {
                        gameData.score[1] += 1
                        gameData.p2CupsLeft[cupHit] = true
                        if gameData.shotHit[0] && gameData.shotHit[1] {
                            gameData.p1Turn = false
                            gameData.shotsRemaining = 2
                        }
                    }
                }
                firebase.gamesRef?.document(gameID).updateData([
                    "p2CupsLeft": gameData.p2CupsLeft,
                    "p2CupsHit": gameData.p2CupsHit,
                    "p1OnRedemption": gameData.p1OnRedemption,
                    "p2OnRedemption": gameData.p2OnRedemption,
                    "p1Turn": gameData.p1Turn,
                    "shotHit": gameData.shotHit,
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
                "score": gameData.score,
                "isFinished": gameData.isFinished,
                "shotHit": gameData.shotHit
            ])
            if gameData.isFinished {
                uploadPlayerStats(winner: gameData.winner)
            }
        }
    }
    
    func uploadPlayerStats(winner: String) {
        if let gameData = gameData {
            players[0].shots += gameData.p1TotalShots
            players[0].shotsHit += gameData.p1CupsHit
            players[0].shotsMissed += gameData.p1TotalShots - gameData.p1CupsHit
            players[0].games += 1
            players[0].shotPercentage = "\(Double(players[0].shotsHit)/Double(players[0].shots))"
            players[1].shots += gameData.p2TotalShots
            players[1].shotsHit += gameData.p2CupsHit
            players[1].shotsMissed += gameData.p2TotalShots - gameData.p1CupsHit
            players[1].games += 1
            players[1].shotPercentage = "\(Double(players[1].shotsHit)/Double(players[1].shots))"
            if winner == players[0].id {
                players[0].wins += 1
                players[1].losses += 1
            } else {
                players[0].losses += 1
                players[1].wins += 1
            }
        }
        for i in 0 ..< 2 {
            firebase.playersRef?.whereField("id", isEqualTo: players[i].id)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            document.reference.updateData([
                                "shots": self.players[i].shots,
                                "shotsHit": self.players[i].shotsHit,
                                "shotsMissed": self.players[i].shotsMissed,
                                "shotPercentage": self.players[i].shotPercentage,
                                "games": self.players[i].games,
                                "wins": self.players[i].wins,
                                "losses": self.players[i].losses,
                                "redemptions": self.players[i].redemptions
                            ])
                        }
                    }
            }
        }
    }
}
