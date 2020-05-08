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
        let nib = UINib(nibName: "LeaderboardsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "statsCell")
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(allPlayers.count)
        return allPlayers.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell", for: indexPath) as! LeaderboardsTableViewCell
        if (indexPath.row > 0) {
            cell.rank.text = "\(allPlayers[indexPath.row - 1].rank)"
            cell.name.text = allPlayers[indexPath.row - 1].firstName
            cell.games.text = "\(allPlayers[indexPath.row - 1].games)"
            cell.wins.text = "\(allPlayers[indexPath.row - 1].wins)"
            cell.losses.text = "\(allPlayers[indexPath.row - 1].losses)"
            cell.shotPercent.text = "\(allPlayers[indexPath.row - 1].shotPercentage)"
        }
        return cell
    }

}
