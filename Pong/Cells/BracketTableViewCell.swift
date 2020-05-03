//
//  BracketTableViewCell.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-04-29.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit

class BracketTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var cupsHit: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
