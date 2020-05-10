//
//  WinnerViewController.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-05-10.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit

class WinnerViewController: UIViewController {

    @IBOutlet var bgView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    var titleText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = titleText
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bgView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bgView.insertSubview(blurEffectView, belowSubview: popUpView)
    }
    
    @IBAction func dismissClicked(_ sender: Any) {
        
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
