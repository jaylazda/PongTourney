//
//  Tournament.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-30.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Tournament: Codable {
    var currentRound: Int
    var games: [DocumentReference]
    var numPlayers: Int
    var registeredPlayers: Int
    var roundFinished: Bool
    var players: [DocumentReference]
    var host: DocumentReference?
    var gamesPerRound: Int
    var tourneyFull: Bool
    
    init() {
        self.currentRound = 1
        self.games = []
        self.numPlayers = 0
        self.registeredPlayers = 0
        self.roundFinished = false
        self.players = []
        self.host = nil
        self.gamesPerRound = 0
        self.tourneyFull = false
    }
}
