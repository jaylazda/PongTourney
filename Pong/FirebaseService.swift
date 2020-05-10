//
//  FirebaseService.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-05-03.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseService {
    
    static let shared = FirebaseService()
    private var db = Firestore.firestore()
    var playersRef: CollectionReference? = nil
    var tournamentsRef: CollectionReference? = nil
    var gamesRef: CollectionReference? = nil
    var docRef: DocumentReference? = nil
    var authentication: Auth? = nil
    var playerIDs: [String] = []
    var tournamentData = Tournament()
    
    init() {
        playersRef = db.collection("users")
        tournamentsRef = db.collection("tournament")
        gamesRef = db.collection("game")
        authentication = Auth.auth()
    }
    
    // MARK: User Signup
    
    func addNewUser(_ email: String, _ password: String, _ firstName: String, _ lastName: String, view: UIViewController) {
        Auth.auth().createUser(withEmail: email, password: password){ (user, error) in
        if error == nil {
            self.addNewUserInfo(firstName, lastName, email)
            view.performSegue(withIdentifier: "signupToHome", sender: self)
                       }
        else{
            let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                               
            alertController.addAction(defaultAction)
            view.present(alertController, animated: true, completion: nil)
              }
                   }
    }
    
    func addNewUserInfo(_ firstName: String, _ lastName: String, _ email: String) {
        docRef = playersRef?.addDocument(data: [
            "id": Auth.auth().currentUser?.uid ?? "",
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "games": 0,
            "wins": 0,
            "losses": 0,
            "shots": 0,
            "shotsMissed": 0,
            "shotsHit": 0,
            "shotPercentage": "0%",
            "redemptions": 0,
            "rank": 1
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(String(describing: self.docRef?.documentID))")
            }
        }
    }
    
    // MARK: User Signin
    
    func signIn(_ email: String, _ password: String, view: UIViewController) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil{
                view.performSegue(withIdentifier: "loginToHome", sender: self)
            } else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                view.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func fetchTournamentDataAndPlayerIDs(_ tourneyID: String, queue: DispatchQueue = .main, completionHandler: @escaping (_ tourneyData: Tournament,_ playerIDs: [String]) -> Void) {
        tournamentsRef?.document(tourneyID)
            .addSnapshotListener { documentSnapshot, error in
                self.playerIDs = []
                guard let document = documentSnapshot else {
                    print("Error fetching document \(error!)")
                    return
                }
                let result = Result {
                     try document.data(as: Tournament.self)
                 }
                 switch result {
                 case .success(let tourney):
                     if let tourney = tourney {
                        self.tournamentData = tourney
                        print(self.tournamentData)
                     } else {
                         print("Tournament is empty")
                     }
                 case .failure(let error):
                     print("Error decoding tournament: \(error)")
                }
                guard let playerArray = document.get("players") as? [DocumentReference] else {
                    print("Error getting player references")
                    return
                }
                for player in playerArray.reversed() {
                    self.playerIDs.append(player.documentID)
                }
                if document.get("tourneyFull") as! Bool {
                    self.addPlayersToGames(tourneyID) {
                        print("Added players to games")
                    }
                }
                queue.async {
                    completionHandler(self.tournamentData, self.playerIDs)
                }
            }
    }
    
    func fetchTournamentDataAndPlayerData(_ tourneyID: String, queue: DispatchQueue = .main, completionHandler: @escaping (_ tourneyData: Tournament,_ playerList: [Player]) -> Void) {
        self.playerIDs = []
        fetchTournamentDataAndPlayerIDs(tourneyID) { tournamentData, playerDocIDs in
            var playerList: [Player] = []
            for id in self.playerIDs {
                print(id)
                self.playersRef?.whereField("id", isEqualTo: id)
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
                                 playerList.insert(player, at: 0)
                                print(player)
                                
                             } else {
                                 print("Player is empty")
                             }
                         case .failure(let error):
                             print("Error decoding player: \(error)")
                            }
                        }
                    }
                        queue.async {
                            completionHandler(tournamentData, playerList)
                        }
                }
            }
        }
    }
    
    func fetchTournamentGameIDs(_ tourneyID: String, queue: DispatchQueue = .main, completionHandler: @escaping (_ gameIDs: [String]) -> Void) {
        tournamentsRef?.document(tourneyID)
            .getDocument() { (documentSnapshot, err) in
                var gameIDs: [String] = []
                guard let document = documentSnapshot else {
                    print("Error fetching document \(err!)")
                    return
                }
                guard let gameArray = document.get("games") as? [DocumentReference] else {
                    print("Error getting game references")
                    return
                }
                for game in gameArray {
                    gameIDs.append(game.documentID)
                }
                queue.async {
                    completionHandler(gameIDs)
                }
            }
    }
    
    func fetchGameData(_ gameID: String, queue: DispatchQueue = .main, completionHandler: @escaping (_ gameData: Game) -> Void) {
        gamesRef?.document(gameID)
            .addSnapshotListener() { (documentSnapshot, error) in
                var gameData = Game()
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                let result = Result {
                    try document.data(as: Game.self)
                }
                switch result {
                case .success(let game):
                    if let game = game {
                        gameData = game
                    } else {
                        print("Game is empty")
                    }
                case .failure(let error):
                    print("Error decoding game: \(error)")
                }
                queue.async {
                    completionHandler(gameData)
                }
            }
    }
    
    func addPlayersToGames(_ tourneyID: String, queue: DispatchQueue = .main, completionHandler: @escaping () -> Void) {
        fetchTournamentGameIDs(tourneyID) { gameIDs in
            var games: [Game] = []
            for (index, game) in gameIDs.enumerated() {
                self.docRef = self.gamesRef?.document(game)
                print(game)
                print(self.playerIDs[2*index])
                print(self.playerIDs[2*index+1])
                self.docRef?.updateData([
                    "player1": self.playerIDs[2*index],
                    "player2": self.playerIDs[2*index+1]
                ])
                self.docRef?.getDocument() { document, error in
                    if let error = error {
                        print("Error getting document: \(error)")
                    } else {
                        let result = Result {
                            try document?.data(as: Game.self)
                        }
                        switch result {
                        case .success(let game):
                            if let game = game {
                                games.append(game)
                            } else {
                                print("Game is empty")
                            }
                        case .failure(let error):
                            print("Error decoding game: \(error)")
                           }
                    }
                }
            }
            queue.async {
                completionHandler()
            }
        }
    }
    
}
