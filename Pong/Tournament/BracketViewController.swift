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

class BracketViewController: UIViewController {

    var numPlayers = 0.0
    var visiblePlayers = 0
    var tourneyID = ""
    var bracketVM: BracketViewModel?
    var firebase = FirebaseService.shared
    var gamesCreated = false
    let segTitles = ["Final", "Semifinal", "Quarterfinal", "16", "32"]
    var seg = 0
    let defaults = UserDefaults()
    
    @IBOutlet weak var leaveTourneyButton: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var segments: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateData()
        initializeSegmentController()
        visiblePlayers = Int(numPlayers)
        idLabel.text = "Tournament ID: \(tourneyID)"
        defaults.set(numPlayers, forKey: "numPlayers")
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "BracketTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "bracketCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: View Setup
    
    func populateData() {
        bracketVM = BracketViewModel(tourneyID)
        bracketVM?.initializeData {
            let group = DispatchGroup()
            group.enter()
            self.bracketVM?.fetchAllPlayers { players in
                self.bracketVM?.playerList = players
                group.leave()
            }
            group.enter()
            self.bracketVM?.fetchAllGames { games in
                self.bracketVM?.allGames = games
                group.leave()
            }
            group.notify(queue: .main) {
                self.bracketVM?.updateGamePlayers()
                self.listenForGameChanges()
                self.tableView.reloadData()
            }
        }
    }
    
    func initializeSegmentController() {
        segments.removeAllSegments()
        print(numPlayers)
        let numSegs = Int(log2(numPlayers))
        for i in 0 ..< numSegs {
            segments.insertSegment(withTitle: segTitles[i], at: 0, animated: true)
        }
        segments.selectedSegmentIndex = 0
    }
    
    func listenForGameChanges() {
        for (round, gameRefs) in bracketVM!.allGameRefs.enumerated() {
            for (index, gameRef) in gameRefs.enumerated() {
                firebase.setUpGameListener(gameRef) {
                    self.firebase.fetchGameData(gameRef) { game in
                        self.bracketVM?.allGames[round][index] = game
                        self.bracketVM?.updateGamePlayers()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: IBActions
    
    @IBAction func segmentChanged(_ sender: Any) {
        seg = segments.selectedSegmentIndex
        if seg != 0 {
            visiblePlayers = Int(numPlayers/(pow(2.0, Double(seg))))
        } else {
            visiblePlayers = Int(numPlayers)
        }
        tableView.reloadData()
    }
    
    @IBAction func leaveTourneyClicked(_ sender: Any) {
        let user = firebase.authentication?.currentUser?.uid ?? ""
        let player = firebase.playersRef?.document(user)
        firebase.tournamentsRef?.document(tourneyID).updateData([
            "tourneyFull": false,
            "players": FieldValue.arrayRemove([player ?? ""]),
            "registeredPlayers": (bracketVM?.playerList.count ?? 1) - 1
        ])
        defaults.removeObject(forKey: user)
        defaults.removeObject(forKey: "numPlayers")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let home = storyboard.instantiateViewController(identifier: "HomeViewController")
        UIApplication.shared.keyWindow?.rootViewController = home
    }
    
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let gameVC = segue.destination as? GameViewController else { return }
        if let indexPath = self.tableView.indexPathForSelectedRow {
            if let game = bracketVM?.allGames[seg][indexPath.section] {
                if let player1 = bracketVM?.playerList.first(where: {$0.id == game.player1}) {
                    if let player2 = bracketVM?.playerList.first(where: {$0.id == game.player2}) {
                        gameVC.players = [player1, player2]
                        gameVC.player1Name = player1.firstName
                        gameVC.player2Name = player2.firstName
                    }
                }
            }
            if let gameRef = bracketVM?.allGameRefs[seg][indexPath.section] {
                gameVC.gameID = gameRef.documentID
            }
        }
    }
    
}

// MARK: Table View

extension BracketViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return visiblePlayers/2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bracketCell") as! BracketTableViewCell
        cell.name.text = "TBD"
        cell.cupsHit.text = "0"
        if !(bracketVM?.allGames.isEmpty ?? true) && !(bracketVM?.allGames[seg].isEmpty ?? true) {
            if let game = bracketVM?.allGames[seg][indexPath.section] {
                if indexPath.row == 0 {
                    if let player = bracketVM?.playerList.first(where: {$0.id == game.player1}) {
                        cell.name.text = player.firstName
                    }
                    if game.winner == game.player2 {
                        cell.contentView.alpha = 0.85
                    } else {
                        cell.contentView.alpha = 1.0
                    }
                } else {
                    if let player = bracketVM?.playerList.first(where: {$0.id == game.player2}) {
                        cell.name.text = player.firstName
                    }
                    if game.winner == game.player1 {
                        cell.contentView.alpha = 0.85
                    } else {
                        cell.contentView.alpha = 1.0
                    }
                }
                cell.cupsHit.text = String(describing: game.score[indexPath.row])
                
            }
        }
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
//        var shadowLayer = CAShapeLayer()
//        shadowLayer.path = UIBezierPath(roundedRect: view.bounds, cornerRadius: 0).cgPath
//        shadowLayer.fillColor = UIColor.red.cgColor
//        shadowLayer.shadowColor = UIColor.black.cgColor
//        shadowLayer.shadowPath = shadowLayer.path
//        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
//        shadowLayer.shadowOpacity = 0.5
//        shadowLayer.shadowRadius = 1
//        view.layer.insertSublayer(shadowLayer, at: 0)
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !(bracketVM?.tournamentData.tourneyFull ?? false) { return }
        if !(bracketVM?.allGames.isEmpty ?? true) && !(bracketVM?.allGames[seg].isEmpty ?? true) {
            if let game = bracketVM?.allGames[seg][indexPath.section] {
                let userID = firebase.authentication?.currentUser?.uid
                if  game.player1 == userID || game.player2 == userID {
                    self.performSegue(withIdentifier: "goToGame", sender: self)
                }
            }
        }
    }
    
}


 
