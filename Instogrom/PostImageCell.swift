//
//  PostImageCell.swift
//  Instogrom
//
//  Created by Paul Ku on 2016/8/5.
//  Copyright © 2016年 hpd.io. All rights reserved.
//

import UIKit

class PostImageCell: UITableViewCell {

    @IBOutlet weak var photoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.frame.size.height = 300
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
