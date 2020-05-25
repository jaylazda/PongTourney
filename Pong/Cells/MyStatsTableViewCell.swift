//
//  MyStatsTableViewCell.swift
//  Pong
//
//  Created by Jacob Lazda on 2020-05-18.
//  Copyright © 2020 Jacob Lazda. All rights reserved.
//

import UIKit

class MyStatsTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var statTypeLabel: UILabel!
    @IBOutlet weak var statNumberLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
