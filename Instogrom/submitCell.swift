//
//  submitCell.swift
//  Instogrom
//
//  Created by Paul Ku on 2016/8/5.
//  Copyright © 2016年 hpd.io. All rights reserved.
//

import UIKit


protocol submitCellDelegate {
    func submitBtnClick(rowCell: submitCell)
}

class submitCell: UITableViewCell {
    
    //MARK: -Properties
    var delegate: submitCellDelegate?
    
    @IBOutlet weak var submitTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func submitMessage(sender: AnyObject) {
        print("submit btn click!")
        delegate?.submitBtnClick(self)
    }
}
