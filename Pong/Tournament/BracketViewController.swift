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
    var playerList: [Player] = []
    var playerDocIDs: [String] = []
    var ref: DocumentReference? = nil
    var db = Firestore.firestore()
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var segments: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    let segTitles = ["Final", "Semifinal", "Quarterfinal", "16", "32"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePlayerList()
        visiblePlayers = Int(numPlayers)
        segments.removeAllSegments()
        addSegments()
        getPlayerInfo()
        segments.selectedSegmentIndex = 0
        idLabel.text = "Tournament ID: \(tourneyID)"
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "BracketTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "bracketCell")
        //Get player from db with current user id and add to playerlist
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        let index = segments.selectedSegmentIndex
        if index != 0 {
            visiblePlayers = Int(numPlayers/(pow(2.0, Double(index))))
        } else {
            visiblePlayers = Int(numPlayers)
        }
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "bracketCell") as! BracketTableViewCell
        if playerList.indices.contains(indexPath.row + (2*indexPath.section)) {
            cell.name.text = playerList[indexPath.row + (2*indexPath.section)].firstName
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
    }
    
    //!!!!!! ADD LISTENERS, WILL ALSO LISTEN TO LOCAL WRITES! SO WHEN A NEW PLAYER JOINS AND IS ADDED TO THE TOURNEYVC, ITLL AUTOMATICALLY UPDATE

    func getPlayerInfo() {
        let newPlayer = Auth.auth().currentUser?.uid ?? ""
        let playersRef = db.collection("users")
        _ = playersRef.whereField("id", isEqualTo: newPlayer)
            .getDocuments() { (querySnapshot, err) in
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
                         self.playerList.append(player)
                     } else {
                         //nil
                     }
                 case .failure(let error):
                     print("Error decoding player: \(error)")
                    }
                }
            }
        }
    }
    
    func updatePlayerList() {
        let tourneyRef = db.collection("tournament").document(tourneyID)
        tourneyRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let refArray = document.get("players") as? [DocumentReference] ?? []
                    for docRef in refArray {
                        self.playerDocIDs.append(docRef.documentID)
                    }
                } else {
                    print("Doc does not exist")
                }
            
            for id in self.playerDocIDs {
                let playersRef = self.db.collection("users")
                _ = playersRef.whereField("id", isEqualTo: id)
                    .getDocuments() { (querySnapshot, err) in
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
                                 self.playerList.append(player)
                             } else {
                                 //nil
                             }
                         case .failure(let error):
                             print("Error decoding player: \(error)")
                            }
                        }
                    }
                }
            
            }
        }
    }
}


