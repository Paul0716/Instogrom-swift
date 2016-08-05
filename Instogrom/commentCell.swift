//
//  commentCell.swift
//  Instogrom
//
//  Created by Paul Ku on 2016/8/5.
//  Copyright © 2016年 hpd.io. All rights reserved.
//

import UIKit

class commentCell: UITableViewCell {

    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
