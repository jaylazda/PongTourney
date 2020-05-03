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
    var player1: Player
    var player2: Player
    var p1Starts: Bool
    var p1CupsLeft: Int
    var p2CupsLeft: Int
    var ballsBack: Bool
}
