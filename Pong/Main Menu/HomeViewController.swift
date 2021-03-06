//
//  HomeViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-27.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var setUpTourneyButton: UIButton!
    @IBOutlet weak var leaderboardsButton: UIButton!
    @IBOutlet weak var myStatsButton: UIButton!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    var allPlayers: [Player] = []
    let defaults = UserDefaults()
    let user = FirebaseService.shared.authentication?.currentUser?.uid ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.setGradientBackground(colorOne: .darkGray, colorTwo: .lightGray)
        setUpTourneyButton.layer.cornerRadius = 25
        leaderboardsButton.layer.cornerRadius = 25
        myStatsButton.layer.cornerRadius = 25
        startGameButton.layer.cornerRadius = 25
        logoutButton.layer.cornerRadius = 25
        //getAllPlayers()
        //defaults.removeObject(forKey: user)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: animated)
    }
    
    @IBAction func tournamentClicked(_ sender: Any) {
        if ((defaults.string(forKey: user)) != nil) {
            self.performSegue(withIdentifier: "goToCurrentTourney", sender: self)
        } else {
            self.performSegue(withIdentifier: "goToNewTournament", sender: self)
        }
    }
    
    @IBAction func leaderboardsClicked(_ sender: Any) {
        
    }
    @IBAction func myStatsClicked(_ sender: Any) {
        
    }
    
    @IBAction func startGameClicked(_ sender: Any) {
        
    }
    
    @IBAction override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        do {
            try FirebaseService.shared.authentication?.signOut()
        } catch let signOutError as NSError {
               print ("Error signing out: %@", signOutError)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }
    // TODO: CHECK IF ALREADY IN TOURNAMENT -> if yes -> go to tournament goToCurrentTourney
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let leaderboardVC = segue.destination as? LeaderboardsTableViewController else {
            guard let tourneyVC = segue.destination as? BracketViewController else {
                return
            }
            tourneyVC.tourneyID = defaults.string(forKey: user)!
            tourneyVC.numPlayers = defaults.double(forKey: "numPlayers")
            return
        }
//        leaderboardVC.allPlayers = self.allPlayers
    }

}

extension UIView {
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
}


class CopyableLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }
    
    func sharedInit() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.showMenu)))
    }
    
    @objc func showMenu(sender: AnyObject?) {
        self.becomeFirstResponder()
        
        let menu = UIMenuController.shared
        
        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        
        board.string = text
        
        let menu = UIMenuController.shared
        
        menu.setMenuVisible(false, animated: true)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy)
    }
}
