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
    var filteredPlayers: [Player] = []
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllPlayers()
        let nib = UINib(nibName: "LeaderboardsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "statsCell")
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Players"
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
        if isFiltering {
            return filteredPlayers.count
        }
        return allPlayers.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell", for: indexPath) as! LeaderboardsTableViewCell
        let player: Player
        if isFiltering {
            player = filteredPlayers[indexPath.row]
        } else {
            player = allPlayers[indexPath.row]
        }
//        if (allPlayers.indices.contains(indexPath.row)) {
            cell.name.text = "\(player.firstName) \(player.lastName)"
            cell.wins.text = "\(player.wins) W"
            cell.losses.text = "\(player.losses) L"
            cell.shotPercent.text = "\(formatPercentage(player.shotPercentage)) Shots Hit"
            cell.redemptions.text = "\(player.redemptions) Redemptions"
//        }
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
    
    func filterContentForSearchText(_ searchText: String) {
        filteredPlayers = allPlayers.filter { (player: Player) -> Bool in
            return player.firstName.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }

}

extension LeaderboardsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
