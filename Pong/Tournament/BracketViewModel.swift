//
//  BracketViewModel.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-05-05.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import Foundation

class BracketViewModel {
    
    let firebase = FirebaseService.shared
    var tournamentID: String
    var tournamentData = Tournament()
    var totalPlayers = 0
    var playerList: [Player] = []
    var allGames: [[Game]] = []
    
    init(_ tournamentID: String) {
        self.tournamentID = tournamentID
    }
    
    func initializeData(completionHandler: @escaping () -> Void) {
        self.firebase.fetchTournamentData(tournamentID) { tournament in
            self.tournamentData = tournament
            self.totalPlayers = tournament.numPlayers
            completionHandler()
        }
    }
    
    func fetchAllPlayers(completionHandler: @escaping (_ players: [Player]) -> Void) {
        var playerList = Array(repeating: Player(), count: totalPlayers)
        let group = DispatchGroup()
        print(tournamentData.players)
        for (index, playerRef) in tournamentData.players.enumerated() {
            print(index, playerRef.documentID)
            group.enter()
            firebase.fetchPlayerData(playerRef) { playerData in
                playerList[index] = playerData
                group.leave()
            }
        }
        group.notify(queue: .main) {
            print("notify triggered")
            completionHandler(playerList)
        }
    }  
    
    func fetchAllGames(completionHandler: @escaping (_ games: [[Game]]) -> Void) {
        var gameList = [Array(repeating: Game(), count: totalPlayers/2),
                        Array(repeating: Game(), count: totalPlayers/4),
                        Array(repeating: Game(), count: totalPlayers/8),
                        Array(repeating: Game(), count: totalPlayers/16),
                        Array(repeating: Game(), count: totalPlayers/32)]
        let allGameRefs = [tournamentData.r1Games, tournamentData.r2Games, tournamentData.r3Games, tournamentData.r4Games, tournamentData.r5Games]
        let group = DispatchGroup()
        for (round, gameRefs) in allGameRefs.enumerated() {
            for (index, gameRef) in gameRefs.enumerated() {
                group.enter()
                firebase.fetchGameData(gameRef) { gameData in
                    gameList[round][index] = gameData
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            print("notify games triggered")
            completionHandler(gameList)
        }
       
        
    }
}
