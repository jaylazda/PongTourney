//
//  Player.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-27.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import Foundation

struct Player: Codable {
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
}
