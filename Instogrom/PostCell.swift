//
//  PostCell.swift
//  Instogrom
//
//  Created by Paul Ku on 2016/8/1.
//  Copyright © 2016年 hpd.io. All rights reserved.
//

import UIKit

protocol PostCellDelegate {
    func postCellLongPress(postCell: PostCell)
    
    func postCellTapped(postCell:PostCell)
    
    func postCellLikeButtonTapped(postCell:PostCell)
}

class PostCell: UITableViewCell {
    
    // MARK: -Properties
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    var delegate: PostCellDelegate?
    var postKey:String = ""
    var imgPath:String = ""
    var longPressGesture: UILongPressGestureRecognizer!
    var tapGesture: UITapGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed) )
        photoImageView.addGestureRecognizer(longPressGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        photoImageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: -longPressed
    func longPressed(){
        if longPressGesture.state == UIGestureRecognizerState.Ended {
            delegate?.postCellLongPress(self)
        }
    }
    
    func cellTapped(){
        if longPressGesture.state == UIGestureRecognizerState.Ended {
            delegate?.postCellTapped(self)
        }
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        delegate?.postCellLikeButtonTapped(self)
    }
    
}
