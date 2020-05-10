//
//  GameViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-29.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var p1Name: UILabel!
    @IBOutlet weak var p2Name: UILabel!
    @IBOutlet weak var p1cup1: UIButton!
    @IBOutlet weak var p1cup2: UIButton!
    @IBOutlet weak var p1cup3: UIButton!
    @IBOutlet weak var p1cup4: UIButton!
    @IBOutlet weak var p1cup5: UIButton!
    @IBOutlet weak var p1cup6: UIButton!
    @IBOutlet weak var p2cup1: UIButton!
    @IBOutlet weak var p2cup2: UIButton!
    @IBOutlet weak var p2cup3: UIButton!
    @IBOutlet weak var p2cup4: UIButton!
    @IBOutlet weak var p2cup5: UIButton!
    @IBOutlet weak var p2cup6: UIButton!
    @IBOutlet weak var p1View: UIView!
    @IBOutlet weak var p2View: UIView!
    @IBOutlet weak var pongTableView: UIView!
    @IBOutlet weak var p1Shot: UIButton!
    @IBOutlet weak var p2Shot: UIButton!
    @IBOutlet weak var p1Balls: UILabel!
    @IBOutlet weak var p2Balls: UILabel!
    var gameID = ""
    var player1Name = ""
    var player2Name = ""
    var players: [Player] = []
    var gameVM: GameViewModel? = nil
    lazy var allP1Cups = [p1cup1, p1cup2, p1cup3, p1cup4, p1cup5, p1cup6]
    lazy var allP2Cups = [p2cup1, p2cup2, p2cup3, p2cup4, p2cup5, p2cup6]
    var winnerName = ""
    var formattedScore = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameVM = GameViewModel(gameID, players)
        initialLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateGameTable()
    }
    
    func initialLayout() {
        p1Name?.text = player1Name
        p2Name?.text = player2Name
        p1Shot.setTitle("\(player1Name)'s Shot", for: .normal)
        p2Shot.setTitle("\(player2Name)'s Shot", for: .normal)
        for cup in allP1Cups {
            cup?.layer.cornerRadius = cup!.frame.size.width/2
        }
        for cup in allP2Cups {
            cup?.layer.cornerRadius = cup!.frame.size.width/2
        }
        p1View.layer.cornerRadius = 15
        p2View.layer.cornerRadius = 15
        pongTableView.layer.cornerRadius = 15
        p1Shot.layer.cornerRadius = 25
        p2Shot.layer.cornerRadius = 25
    }
    
    func setAllButtons() {
        if gameVM?.gameData?.p1Turn ?? true {
            p1Shot.isEnabled = true
            for cup in allP2Cups {
                cup?.isEnabled = true
            }
            p2Shot.isEnabled = false
            for cup in allP1Cups {
                cup?.isEnabled = false
            }
        } else {
            p2Shot.isEnabled = true
            for cup in allP1Cups {
                cup?.isEnabled = true
            }
            p1Shot.isEnabled = false
            for cup in allP2Cups {
                cup?.isEnabled = false
            }
        }
    }
    
    // MARK: Shot Button Actions
    
    @IBAction func p1ShotClicked(_ sender: Any) {
        if p1Shot.titleLabel?.text == "\(player1Name)'s Shot" {
            if gameVM?.gameData?.shotsRemaining == 1 {
                p1Shot.setTitle("End Turn", for: .normal)
            } else {
                p1Shot.setTitle("Miss", for: .normal)
            }
            gameVM?.playerDidShoot(player: players[0])
            UIView.animate(withDuration: 1.0, animations: {
                self.p2cup1.alpha = 0.0
                self.p2cup4.alpha = 0.0
                self.p2cup6.alpha = 0.0
            })
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                UIView.animate(withDuration: 1.0, animations: {
                               self.p2cup2.alpha = 0.0
                               self.p2cup3.alpha = 0.0
                               self.p2cup5.alpha = 0.0
                           })
            }
            UIView.animate(withDuration: 1.0, animations: {
                self.p2cup1.alpha = 1.0
                self.p2cup4.alpha = 1.0
                self.p2cup6.alpha = 1.0
            })
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                UIView.animate(withDuration: 1.0, animations: {
                               self.p2cup2.alpha = 1.0
                               self.p2cup3.alpha = 1.0
                               self.p2cup5.alpha = 1.0
                           })
            }
        } else if p1Shot.titleLabel?.text == "Miss" {
            p1Shot.setTitle("\(player1Name)'s Shot", for: .normal)
        } else if p1Shot.titleLabel?.text == "End Turn" {
            p1Shot.setTitle("\(player1Name)'s Shot", for: .normal)
            gameVM?.playerTurnFinished(player: players[0])
        }
        
    }
    
    @IBAction func p2ShotClicked(_ sender: Any) {
        if p2Shot.titleLabel?.text == "\(player2Name)'s Shot" {
            if gameVM?.gameData?.shotsRemaining == 1 {
                p2Shot.setTitle("End Turn", for: .normal)
            } else {
                p2Shot.setTitle("Miss", for: .normal)
            }
            gameVM?.playerDidShoot(player: players[1])
            UIView.animate(withDuration: 1.0, animations: {
                self.p1cup1.alpha = 0.0
                self.p1cup4.alpha = 0.0
                self.p1cup6.alpha = 0.0
            })
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                UIView.animate(withDuration: 1.0, animations: {
                               self.p1cup2.alpha = 0.0
                               self.p1cup3.alpha = 0.0
                               self.p1cup5.alpha = 0.0
                           })
            }
            UIView.animate(withDuration: 1.0, animations: {
                self.p1cup1.alpha = 1.0
                self.p1cup4.alpha = 1.0
                self.p1cup6.alpha = 1.0
            })
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                UIView.animate(withDuration: 1.0, animations: {
                               self.p1cup2.alpha = 1.0
                               self.p1cup3.alpha = 1.0
                               self.p1cup5.alpha = 1.0
                           })
            }
        } else if p2Shot.titleLabel?.text == "Miss" {
            p2Shot.setTitle("\(player2Name)'s Shot", for: .normal)
        } else if p2Shot.titleLabel?.text == "End Turn" {
            p2Shot.setTitle("\(player2Name)'s Shot", for: .normal)
            gameVM?.playerTurnFinished(player: players[1])
        }
    }
    
    // MARK: Cup Button Actions
    
    @IBAction func p1cup1Clicked(_ sender: Any) {
        if p2Shot.titleLabel?.text == "Miss" {
            p2Shot.setTitle("\(player2Name)'s Shot", for: .normal)
        }
        gameVM?.playerShotScored(cupHit: 0, player: (gameVM?.players[1])!)
    }
    
    @IBAction func p1cup2Clicked(_ sender: Any) {
        if p2Shot.titleLabel?.text == "Miss" {
            p2Shot.setTitle("\(player2Name)'s Shot", for: .normal)
        }
        gameVM?.playerShotScored(cupHit: 1, player: (gameVM?.players[1])!)
    }
    
    @IBAction func p1cup3Clicked(_ sender: Any) {
        if p2Shot.titleLabel?.text == "Miss" {
            p2Shot.setTitle("\(player2Name)'s Shot", for: .normal)
        }
        gameVM?.playerShotScored(cupHit: 2, player: (gameVM?.players[1])!)
    }
    
    @IBAction func p1cup4Clicked(_ sender: Any) {
        if p2Shot.titleLabel?.text == "Miss" {
            p2Shot.setTitle("\(player2Name)'s Shot", for: .normal)
        }
        gameVM?.playerShotScored(cupHit: 3, player: (gameVM?.players[1])!)
    }
    
    @IBAction func p1cup5Clicked(_ sender: Any) {
        if p2Shot.titleLabel?.text == "Miss" {
            p2Shot.setTitle("\(player2Name)'s Shot", for: .normal)
        }
        gameVM?.playerShotScored(cupHit: 4, player: (gameVM?.players[1])!)
    }
    
    @IBAction func p1cup6Clicked(_ sender: Any) {
        if p2Shot.titleLabel?.text == "Miss" {
            p2Shot.setTitle("\(player2Name)'s Shot", for: .normal)
        }
        gameVM?.playerShotScored(cupHit: 5, player: (gameVM?.players[1])!)
    }
    
    @IBAction func p2cup1Clicked(_ sender: Any) {
        if p1Shot.titleLabel?.text == "Miss" {
            p1Shot.setTitle("\(player1Name)'s Shot", for: .normal)
        }
        gameVM?.playerShotScored(cupHit: 0, player: (gameVM?.players[0])!)
    }
    
    @IBAction func p2cup2Clicked(_ sender: Any) {
        if p1Shot.titleLabel?.text == "Miss" {
            p1Shot.setTitle("\(player1Name)'s Shot", for: .normal)
        }
        gameVM?.playerShotScored(cupHit: 1, player: (gameVM?.players[0])!)
    }
    
    @IBAction func p2cup3Clicked(_ sender: Any) {
        if p1Shot.titleLabel?.text == "Miss" {
            p1Shot.setTitle("\(player1Name)'s Shot", for: .normal)
        }
        gameVM?.playerShotScored(cupHit: 2, player: (gameVM?.players[0])!)
    }
    
    @IBAction func p2cup4Clicked(_ sender: Any) {
        if p1Shot.titleLabel?.text == "Miss" {
            p1Shot.setTitle("\(player1Name)'s Shot", for: .normal)
        }
        gameVM?.playerShotScored(cupHit: 3, player: (gameVM?.players[0])!)
    }
    
    @IBAction func p2cup5Clicked(_ sender: Any) {
        if p1Shot.titleLabel?.text == "Miss" {
            p1Shot.setTitle("\(player1Name)'s Shot", for: .normal)
        }
        gameVM?.playerShotScored(cupHit: 4, player: (gameVM?.players[0])!)
    }
    
    @IBAction func p2cup6Clicked(_ sender: Any) {
        if p1Shot.titleLabel?.text == "Miss" {
            p1Shot.setTitle("\(player1Name)'s Shot", for: .normal)
        }
        gameVM?.playerShotScored(cupHit: 5, player: (gameVM?.players[0])!)
    }
    
    // MARK: Update Views
    
    func layoutPongBalls() {
        if gameVM?.gameData?.p1Turn ?? true {
            if gameVM?.gameData?.p1OnRedemption ?? false {
                p1Balls.textColor = .red
            } else {
                p1Balls.textColor = .orange
            }
            p2Balls.text = "     "
            switch gameVM?.gameData?.shotsRemaining {
            case 2:
                p1Balls.text = " "
            case 1:
                p1Balls.text = "   "
            default:
                break
            }
        } else {
            if gameVM?.gameData?.p2OnRedemption ?? false {
                p2Balls.textColor = .red
            } else {
                p2Balls.textColor = .orange
            }
            p1Balls.text = "     "
            switch gameVM?.gameData?.shotsRemaining {
            case 2:
                p2Balls.text = " "
            case 1:
                p2Balls.text = "   "
            default:
                break
            }
        }
    }
    
    //Change shot titles and stuff here not when shot clicked
    func updateGameTable() {
        gameVM?.fetchGameData(gameID) { game in
            self.layoutPongBalls()
            self.setAllButtons()
            for (index, cupHit) in game.p1CupsLeft.enumerated() {
                if cupHit {
                    self.allP2Cups[index]?.isHidden = true
                } else {
                    self.allP2Cups[index]?.isHidden = false
                }
            }
            for (index, cupHit) in game.p2CupsLeft.enumerated() {
                if cupHit {
                    self.allP1Cups[index]?.isHidden = true
                } else {
                    self.allP1Cups[index]?.isHidden = false
                }
            }
            if game.winner != "" {
                if game.winner == self.players[0].id {
                    self.winnerName = self.player1Name
                    self.formattedScore = "\(game.score[0])-\(game.score[1])"
                } else {
                    self.winnerName = self.player2Name
                    self.formattedScore = "\(game.score[1])-\(game.score[0])"
                }
                self.performSegue(withIdentifier: "winnerPopUp", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let winnerVC = segue.destination as? WinnerViewController else { return }
        winnerVC.titleText = "\(winnerName) wins \(formattedScore)!"
    }
}
