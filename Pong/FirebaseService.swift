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
    var winners: [[String]] = [[], [], [], [], []]
    
    init() {
        playersRef = db.collection("users")
        tournamentsRef = db.collection("tournament")
        gamesRef = db.collection("game")
        authentication = Auth.auth()
    }
    
    // MARK: User Signup
    
    /**
     Attempts to add a new user to Firebase
     - Parameters:
      - email: User's email as a string
      - password: User's password as a string
      - firstName: User's first name as a string
      - lastName: User's last name as a string
      - view: UIViewController from which function was called
     */
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
    /**
     Initializes Player data when a new user is created
     - Parameters:
      - firstName: User's first name as a string
      - lastName: User's last name as a string
      - email: User's email as a string
     */
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
    
    /**
     Attempts to sign the user in to Firebase Authentication platform
     - Parameters:
      - email: User's email address as a string
      - password: User's password as a string
      - view: UIViewController from which function was called
     */
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
    
    // MARK: Fetch Data from Firestore
    
    /**
     Retrieves a Tournament object with the given tournament ID from the database.
     - Parameters:
      - tourneyID: The ID of the tournament being fetched
      - queue: Thread to be called on (main by default)
      - completionHandler: Returns the Tournament object upon completion
     - Returns: Corresponding Tournament object
     */
    func fetchTournamentData(_ tourneyID: String, queue: DispatchQueue = .main, completionHandler: @escaping (_ tourneyData: Tournament) -> Void) {
        var tournamentData = Tournament()
        tournamentsRef?.document(tourneyID)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching tournament \(error!)")
                    return
                }
                let result = Result {
                    try document.data(as: Tournament.self)
                }
                switch result {
                 case .success(let tourney):
                     if let tourney = tourney {
                        tournamentData = tourney
                        print("Received tournament data from server.")
                     } else {
                         print("Tournament is empty")
                     }
                 case .failure(let error):
                     print("Error decoding tournament: \(error)")
                }
            completionHandler(tournamentData)
        }
    }
    
    /**
     Retrieves a Player Object with the given Document Reference from the database.
     - Parameters:
      - playerRef: The Document Reference of the Player being fetched
      - queue: Thread to be called on (main by default)
      - completionHandler: Returns the Player object upon completion
     - Returns: Corresponding Player object
    */
    func fetchPlayerData(_ playerRef: DocumentReference, queue: DispatchQueue = .main, completionHandler: @escaping (_ playerData: Player) -> Void) {
        var playerData = Player()
        playersRef?.whereField("id", isEqualTo: playerRef.documentID)
            .getDocuments() { querySnapshot, error in
                if let err = error {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let result = Result {
                            try document.data(as: Player.self)
                        }
                        switch result {
                        case .success(let player):
                            if let player = player {
                                playerData = player
                                print(playerData)
                                print("Received player data from server.")
                            } else {
                                print("Player is empty")
                            }
                        case .failure(let error):
                            print("Error decoding player: \(error)")
                        }
                    }
                completionHandler(playerData)
            }
        }
    }
    
    /**
    Retrieves a Game Object with the given Document Reference from the database.
    - Parameters:
     - gameRef: The Document Reference of the Game being fetched
     - queue: Thread to be called on (main by default)
     - completionHandler: Returns the Game object upon completion
    - Returns: Corresponding Game object
    */
    func fetchGameData(_ gameRef: DocumentReference, queue: DispatchQueue = .main, completionHandler: @escaping (_ gameData: Game) -> Void) {
        var gameData = Game()
        gameRef.getDocument { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching game \(error!)")
                return
            }
            let result = Result {
                try document.data(as: Game.self)
            }
            switch result {
             case .success(let game):
                 if let game = game {
                    gameData = game
                    print("Received game data from server.")
                 } else {
                     print("Game is empty")
                 }
             case .failure(let error):
                 print("Error decoding game: \(error)")
            }
            completionHandler(gameData)
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
    
    //GET R1,R2,R3,R4,R5 and add to 2d array gameIDs
    func fetchTournamentGameIDs(_ tourneyID: String, queue: DispatchQueue = .main, completionHandler: @escaping (_ gameIDs: [[String]]) -> Void) {
        tournamentsRef?.document(tourneyID)
            .getDocument() { (documentSnapshot, err) in
                var gameIDs: [[String]] = [[], [], [], [], []]
                guard let document = documentSnapshot else {
                    print("Error fetching document \(err!)")
                    return
                }
                var rounds = 1
                guard let numPlayers = document.get("numPlayers") as? Int else {
                    return
                }
                rounds = Int(log2(Double(numPlayers)))
                for i in 0 ..< rounds {
                    print("I is \(i)")
                    guard let gameArray = document.get("r\(i+1)Games") as? [DocumentReference] else {
                        print("Error getting game references")
                        return
                    }
                    for game in gameArray {
                        gameIDs[i].append(game.documentID)
                    }
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
    
    func fetchGameDataNoListener(_ gameID: String, queue: DispatchQueue = .main, completionHandler: @escaping (_ gameData: Game) -> Void) {
        gamesRef?.document(gameID)
        .getDocument() { (documentSnapshot, error) in
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
            self.winners = [Array(repeating: "", count: 16), Array(repeating: "", count: 8), Array(repeating: "", count: 4), ["", ""], [""]]
            self.updatePlayersForRound(1, gameIDs[0])
            self.updatePlayersForRound(2, gameIDs[1])
            self.updatePlayersForRound(3, gameIDs[2])
            self.updatePlayersForRound(4, gameIDs[3])
            self.updatePlayersForRound(5, gameIDs[4])
            queue.async {
                completionHandler()
            }
        }
    }
    
    func updateWinners(_ round: Int,_ roundGameIDs: [String], completionHandler: @escaping () -> Void) {
        let myGroup = DispatchGroup()
        for (index, gameID) in roundGameIDs.enumerated() {
            print(gameID)
            myGroup.enter()
            self.fetchGameDataNoListener(gameID) { gameData in
                print("winner of game \(gameData.id) \(gameData.winner)")
                self.winners[round-1][index] = gameData.winner
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
            completionHandler()
        }
    }
    
    func updatePlayersForRound(_ round: Int,_ roundGameIDs: [String]) {
        self.updateWinners(round, roundGameIDs) {
            for (index, gameID) in roundGameIDs.enumerated() {
                let gameRef = self.gamesRef?.document(gameID)
                if round == 1 {
                    gameRef?.updateData([
                        "player1": self.playerIDs[2*index],
                        "player2": self.playerIDs[2*index+1]
                    ])
                } else {
                    print("winners: \(self.winners)")
                    print(self.winners[round-2][2*index])
                    gameRef?.updateData([
                        "player1": self.winners[round-2][2*index],
                        "player2": self.winners[round-2][2*index+1]
                    ])
                }
            }
        }
    }
    
}
