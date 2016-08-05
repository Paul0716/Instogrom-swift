//
//  PostViewController.swift
//  Instogrom
//
//  Created by Paul Ku on 2016/8/3.
//  Copyright © 2016年 hpd.io. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabaseUI

class PostViewController: UIViewController,UITableViewDelegate{
    
    // MARK: - Properties
    
    var postCell: PostCell!
    var ref:FIRDatabaseReference!
    var postRef:FIRDatabaseReference!
    var dataSource: FirebaseTableViewDataSource!
    var dataArray: FirebaseArray!
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var CommentList: UITableView!
    @IBOutlet weak var CommentTextField: UITextField!
    @IBOutlet weak var submitComment: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.CommentList.delegate? = self
        self.postViewInit()
    }
    
    // MARK: init function
    func postViewInit(){
        
        
        self.photoImage.image = self.postCell.photoImageView?.image
        ref = FIRDatabase.database().reference()
        postRef = ref.child("posts").child(self.postCell.postKey).child("Comments")
        
        dataArray = FirebaseArray(ref: postRef)
        dataSource = FirebaseTableViewDataSource(query: postRef, prototypeReuseIdentifier: "Comments", view: self.CommentList)
         dataSource.populateCellWithBlock { cell, snapshot in
         let snapshot = snapshot as! FIRDataSnapshot
         let comment = snapshot.value as! [String:AnyObject]
         cell.detailTextLabel?.text = comment["email"] as! String
         cell.textLabel?.text = comment["message"] as! String
         
         dispatch_async(dispatch_get_main_queue()){
         var frame: CGRect = self.CommentList.frame;
         frame.size.height = CGFloat( 44 * self.dataArray.count() );
         
         print("update view. size height: \(frame.size.height), content size: \(self.CommentList.contentSize.height) ")
         self.CommentList.frame = frame;
         }
        }
        self.CommentList.dataSource = dataSource
        self.CommentList.rowHeight = UITableViewAutomaticDimension
        self.CommentList.estimatedRowHeight = 44
        /*
        dispatch_async(dispatch_get_main_queue()){
            var frame: CGRect = self.CommentList.frame;
            let contentHeight = CGFloat( 44 * self.dataArray.count() );
            
            print("update view. size height: \(frame.size.height), content size: \(self.CommentList.style.rawValue) ")
            self.CommentList.superview!.frame.size.height = contentHeight;
            
        }
        */
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func addComment(sender: AnyObject) {
        let text = self.CommentTextField?.text!
        if( text == "" ){
            print("text field is empty.")
            return
        }
        
        if let currentUser = FIRAuth.auth()?.currentUser,
                message = self.CommentTextField?.text {
            let postDate = Int(NSDate().timeIntervalSince1970 * 1000)
            
            let comment: [String:AnyObject] = [
                "autherUID" :   currentUser.uid,
                "email" : currentUser.email!,
                "message" : message,
                "publishDate" : NSNumber(integer: postDate),
                "publishDateReversed": NSNumber( integer: -postDate)
            ]
            let postRef = self.postRef.childByAutoId()
            postRef.updateChildValues(comment)
        }
    }
    
    /*
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int
    {
        print(self.dataArray.count())
        return Int(dataArray.count())
    }
    */
    
    /*
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Comments")
        return cell
    }
     */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
