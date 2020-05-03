//
//  GameViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-29.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

   
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let allCups = [p1cup1, p1cup2, p1cup3, p1cup4, p1cup5, p1cup6, p2cup1, p2cup2, p2cup3, p2cup4, p2cup5, p2cup6]
        for cup in allCups {
            cup?.layer.cornerRadius = cup!.frame.size.width/2
        }
        p1View.layer.cornerRadius = 15
        p2View.layer.cornerRadius = 15
        pongTableView.layer.cornerRadius = 15
        p1Shot.layer.cornerRadius = 25
        p2Shot.layer.cornerRadius = 25
    }
    
    @IBAction func p1ShotClicked(_ sender: Any) {
        if p1Shot.titleLabel?.text == "Player 1 Shot" {
            p1Shot.setTitle("Miss", for: .normal)
            UIView.animate(withDuration: 1.0, animations: {
                self.p1cup1.alpha = 0.0
                self.p1cup2.alpha = 0.0
                self.p1cup3.alpha = 0.0
                self.p1cup4.alpha = 0.0
                self.p1cup5.alpha = 0.0
                self.p1cup6.alpha = 0.0
            })
            UIView.animate(withDuration: 1.0, animations: {
                self.p1cup1.alpha = 1.0
                self.p1cup2.alpha = 1.0
                self.p1cup3.alpha = 1.0
                self.p1cup4.alpha = 1.0
                self.p1cup5.alpha = 1.0
                self.p1cup6.alpha = 1.0
            })
        } else if p1Shot.titleLabel?.text == "Miss"{
            p1Shot.setTitle("Player 1 Shot", for: .normal)
        }
    }
    
    @IBAction func p2ShotClicked(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
