//
//  Game.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-30.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import Foundation

struct Game: Codable {
    var id: String
    var player1: String
    var player2: String
    var p1Turn: Bool
    var p1CupsLeft = [false, false, false, false, false, false]
    var p2CupsLeft = [false, false, false, false, false, false]
    var ballsBack: Bool
    var shotsRemaining: Int
    var p1TotalShots: Int
    var p2TotalShots: Int
    var p1CupsHit: Int
    var p2CupsHit: Int
    var p1OnRedemption: Bool
    var p2OnRedemption: Bool
    var score: [Int]
    var winner: String
    var isFinished: Bool
    var shotHit: [Bool]
    
    init() {
        self.id = ""
        self.player1 = ""
        self.player2 = ""
        self.p1Turn = true
        self.p1CupsHit = 0
        self.p2CupsHit = 0
        self.ballsBack = false
        self.shotsRemaining = 2
        self.p1TotalShots = 0
        self.p2TotalShots = 0
        self.p1OnRedemption = false
        self.p2OnRedemption = false
        self.score = [0, 0]
        self.winner = ""
        self.isFinished = false
        self.shotHit = [false, false]
    }
    
    init(id: String) {
        self.id = id
        self.player1 = ""
        self.player2 = ""
        self.p1CupsHit = 0
        self.p2CupsHit = 0
        self.p1Turn = true
        self.ballsBack = false
        self.shotsRemaining = 2
        self.p1TotalShots = 0
        self.p2TotalShots = 0
        self.p1OnRedemption = false
        self.p2OnRedemption = false
        self.score = [0, 0]
        self.winner = ""
        self.isFinished = false
        self.shotHit = [false, false]
    }
}
