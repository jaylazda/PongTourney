//
//  LeaderboardsTableViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-27.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit


class LeaderboardsTableViewController: UITableViewController {
    
    var allPlayers: [Player] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllPlayers()
        let nib = UINib(nibName: "LeaderboardsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "statsCell")
        
        
    }
    
    func getAllPlayers() {
        FirebaseService.shared.playersRef?.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                 let result = Result {
                     try document.data(as: Player.self)
                 }
                 switch result {
                 case .success(let player):
                     if let player = player {
                         self.allPlayers.append(player)
                     } else {
                         print("Player is empty")
                     }
                 case .failure(let error):
                     print("Error decoding player: \(error)")
                 }
                }
            }
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPlayers.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell", for: indexPath) as! LeaderboardsTableViewCell
        if (allPlayers.indices.contains(indexPath.row)) {
            cell.name.text = "\(allPlayers[indexPath.row].firstName) \(allPlayers[indexPath.row].lastName)"
            cell.wins.text = "\(allPlayers[indexPath.row].wins) W"
            cell.losses.text = "\(allPlayers[indexPath.row].losses) L"
            cell.shotPercent.text = "\(formatPercentage(allPlayers[indexPath.row].shotPercentage)) Shots Hit"
            cell.redemptions.text = "\(allPlayers[indexPath.row].redemptions) Redemptions"
        }
        return cell
    }
    
    func formatPercentage(_ shotPercentage: String) -> String {
        if shotPercentage == "0" { return "\(shotPercentage)%" }
        var formatted = shotPercentage.prefix(4)
        if formatted.count == 3 {
            formatted += "0"
        }
        formatted = formatted.suffix(2)
        return "\(String(formatted))%"
    }

}
