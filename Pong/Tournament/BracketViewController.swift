//
//  BracketViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-29.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class BracketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var numPlayers = 0.0
    var visiblePlayers = 0
    var tourneyID = ""
    var playerList: [[Player]] = [[],[],[],[],[]]
    var playerDocIDs: [String] = []
    var firebase = FirebaseService.shared
    var allGameIDs: [[String]] = [[],[],[],[],[]]
    var allGames: [[Game]] = [[],[],[],[],[]]
    var winnerIDs: [String] = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
    var tourneyData = Tournament()
    var gamesCreated = false

    @IBOutlet weak var leaveTourneyButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var segments: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    let segTitles = ["Final", "Semifinal", "Quarterfinal", "16", "32"]
    let defaults = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visiblePlayers = Int(numPlayers)
        segments.removeAllSegments()
        addSegments()
        segments.selectedSegmentIndex = 0
        for i in 0 ..< segments.numberOfSegments {
            let numGames = Int(numPlayers/(pow(2.0, Double(i))))/2
            allGames[i] = Array(repeating: Game(), count: numGames)
        }
        leaveTourneyButton.layer.cornerRadius = 25
        defaults.set(numPlayers, forKey: "numPlayers")
        idLabel.text = "Tournament ID: \(tourneyID)"
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "BracketTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "bracketCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let seg = segments.selectedSegmentIndex
        firebase.fetchTournamentDataAndPlayerData(tourneyID) { tourneyData, players in
            self.tourneyData = tourneyData
            print("PLAYERS \(players)")
            self.playerList[0] = players
            self.tableView.reloadData()
        }
        firebase.fetchTournamentGameIDs(tourneyID) { gameIDs in
            self.allGameIDs = gameIDs
            print(self.allGameIDs)
            self.reloadGameData()
        }
    }
    
    func reloadGameData() {
        var roundFinished = true
        let seg = segments.selectedSegmentIndex
        print(allGameIDs)
        for (index, gameID) in allGameIDs[seg].enumerated() {
            self.firebase.fetchGameData(gameID) { gameData in
                self.allGames[seg][index] = gameData
                if let player = self.playerList[seg-1].first(where: {$0.id == self.allGames[seg][index].player1}) {
                    self.playerList[seg].append(player)
                }
                if let player = self.playerList[seg-1].first(where: {$0.id == self.allGames[seg][index].player2}) {
                    self.playerList[seg].append(player)
                }
                print(self.allGames[seg])
                if !gameData.isFinished {
                    roundFinished = false
                } else {
                    self.winnerIDs[index] = gameData.winner
                    print("WINNERS:\(self.winnerIDs)")
                }
                self.tableView.reloadData()
            }
        }
        if roundFinished {
            
        }
        firebase.tournamentsRef?.document(tourneyID).updateData([
            "roundFinished": roundFinished, // TODO: initialize next round of winners
            "currentRound": tourneyData.currentRound+1 //dont need here
        ])
    }
    @IBAction func segmentChanged(_ sender: Any) {
        let index = segments.selectedSegmentIndex
        if index != 0 {
            visiblePlayers = Int(numPlayers/(pow(2.0, Double(index))))
        } else {
            visiblePlayers = Int(numPlayers)
        }
        tableView.reloadData()
        self.reloadGameData()
    }
    
    @IBAction func leaveTourneyClicked(_ sender: Any) {
        let user = firebase.authentication?.currentUser?.uid ?? ""
        let player = firebase.playersRef?.document(user)
        firebase.tournamentsRef?.document(tourneyID).updateData([
            "tourneyFull": false,
            "players": FieldValue.arrayRemove([player ?? ""]),
            "registeredPlayers": playerList.count-1
        ])
        defaults.removeObject(forKey: user)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let home = storyboard.instantiateViewController(identifier: "HomeViewController")
        UIApplication.shared.keyWindow?.rootViewController = home
    }
    
    func addSegments() {
        print(numPlayers)
        let numSegs = Int(log2(numPlayers))
        for i in 0 ..< numSegs {
            segments.insertSegment(withTitle: segTitles[i], at: 0, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return visiblePlayers/2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let seg = segments.selectedSegmentIndex
        let cell = tableView.dequeueReusableCell(withIdentifier: "bracketCell") as! BracketTableViewCell
        if indexPath.row == 0 {
            if let player = playerList[0].first(where: {$0.id == allGames[seg][indexPath.section].player1}) {
                cell.name.text = player.firstName
            } else {
                cell.name.text = "TBD"
            }
        } else {
            if let player = playerList[0].first(where: {$0.id == allGames[seg][indexPath.section].player2}) {
                cell.name.text = player.firstName
            } else {
                cell.name.text = "TBD"
            }
        }
        cell.cupsHit.text = String(allGames[seg][indexPath.section].score[indexPath.row])
//        if playerList[seg].indices.contains(indexPath.row + (2*indexPath.section)) && allGames[seg].indices.contains(indexPath.section){
//            cell.name.text = playerList[seg][indexPath.row + (2*indexPath.section)].firstName
//
//        } else {
//            cell.name.text = "TBD"
//            cell.cupsHit.text = "0"
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = tableView.backgroundColor
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = tableView.backgroundColor
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let seg = segments.selectedSegmentIndex
        if playerList[seg].indices.contains(2*indexPath.section) && playerList[seg].indices.contains(1+2*indexPath.section){
            let userID = firebase.authentication?.currentUser?.uid
            let player1ID = playerList[seg][2*indexPath.section].id
            let player2ID = playerList[seg][1+2*indexPath.section].id
            if  player1ID == userID || player2ID == userID {
                self.performSegue(withIdentifier: "goToGame", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let seg = segments.selectedSegmentIndex
        guard let gameVC = segue.destination as? GameViewController else { return }
        if let indexPath = self.tableView.indexPathForSelectedRow {
            gameVC.player1Name = playerList[seg][2*indexPath.section].firstName // NOT NECESSARY ANYMORE PASSING IN PLAYERS
            gameVC.player2Name = playerList[seg][1 + (2*indexPath.section)].firstName
            gameVC.players = [playerList[seg][2*indexPath.section], playerList[seg][1 + (2*indexPath.section)]]
            gameVC.gameID = allGameIDs[seg][indexPath.section]
        }
    }
    
}


 
