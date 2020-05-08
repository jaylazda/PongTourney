//
//  Player.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-27.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import Foundation

struct Player: Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var rank: Int
    var games: Int
    var wins: Int
    var losses: Int
    var shots: Int
    var shotsHit: Int
    var shotsMissed: Int
    var shotPercentage: String
    var redemptions: Int
    
    init() {
        self.id = ""
        self.firstName = ""
        self.lastName = ""
        self.email = ""
        self.rank = 0
        self.games = 0
        self.wins = 0
        self.losses = 0
        self.shots = 0
        self.shotsHit = 0
        self.shotsMissed = 0
        self.shotPercentage = "0%"
        self.redemptions = 0
    }
}
