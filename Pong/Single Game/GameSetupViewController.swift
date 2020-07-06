//
//  GameSetupViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-05-17.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit

class GameSetupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var createGameButton: UIButton!
    @IBOutlet weak var gameIDTextField: UITextField!
    @IBOutlet weak var joinGameButton: UIButton!
    let firebase = FirebaseService.shared
    var gameID = ""
    var game = Game()

    override func viewDidLoad() {
        super.viewDidLoad()
        gameIDTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func createGameClicked(_ sender: Any) {
        
        let result = Result {
            self.firebase.docRef = try self.firebase.gamesRef?.addDocument(from: self.game)
        }
        switch result {
        case .success:
            print("Game successfully added")
            self.gameID = self.firebase.docRef?.documentID as! String
        case .failure(let error):
            print("Error encoding game: \(error)")
        }
        self.game.player1 = self.firebase.authentication?.currentUser?.uid as! String
        self.firebase.gamesRef?.document(self.gameID).updateData([
            "player1": self.game.player1
        ])
        self.performSegue(withIdentifier: "goToWaitingRoom", sender: self)
    }
    
    @IBAction func joinGameClicked(_ sender: Any) {
        checkIfGameExists()
    }
    
    func checkIfGameExists() {
        gameID = gameIDTextField.text ?? ""
        firebase.docRef = firebase.gamesRef?.document(gameID)
        firebase.docRef?.getDocument { (document, error) in
                if let document = document, document.exists {
                    let result = Result {
                        self.game = try document.data(as: Game.self)!
                    }
                    switch result {
                    case .success:
                        print("Game successfully decoded")
                    case .failure(let error):
                        print("Error decoding game: \(error)")
                    }
                    self.game.player2 = self.firebase.authentication?.currentUser?.uid as! String
                    self.firebase.gamesRef?.document(self.gameID).updateData([
                        "player2": self.game.player2
                    ])
                    self.performSegue(withIdentifier: "goToWaitingRoom", sender: self)
            
                } else {
                    let alertController = UIAlertController(title: "Error", message: "Game does not exist.", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let waitingRoomVC = segue.destination as? WaitingRoomViewController else { return }
        waitingRoomVC.gameID = gameID
//        guard let gameVC = segue.destination as? GameViewController else { return }
//        gameVC.gameID = gameID
//        gameVC.player1Name = game.player1
//        gameVC.player2Name = game.player2
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
