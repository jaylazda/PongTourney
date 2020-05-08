//
//  Tournament.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-30.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import Foundation

struct Tournament: Codable {
    var numPlayers: Int
    var players: [Player]
    var host: Player
    var gamesPerRound: Int
    var currentGames: [Game]
}
