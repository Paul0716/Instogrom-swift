//
//  PostTableViewController.swift
//  Instogrom
//
//  Created by Paul Ku on 2016/8/5.
//  Copyright © 2016年 hpd.io. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabaseUI

class PostTableViewController: UITableViewController, submitCellDelegate {
    
    var postCell: PostCell!
    var ref:FIRDatabaseReference!
    var postRef:FIRDatabaseReference!
    var comments = [String:AnyObject]()
    var cell_total_count:Int = 0
//    var dataSource: FirebaseTableViewDataSource!
//    var dataArray: FirebaseArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        ref = FIRDatabase.database().reference()
        postRef = ref.child("posts").child(postCell.postKey).child("Comments")
        postRef.observeEventType(FIRDataEventType.Value, withBlock: {
            snapshot in
            if let post = snapshot.value as? [String:AnyObject] {
                self.comments = post
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows\
        let baseCount :Int = 2
        self.cell_total_count = comments.count + baseCount
        return self.cell_total_count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if( indexPath.row == 0 ){
            let cell = tableView.dequeueReusableCellWithIdentifier("imgCell", forIndexPath: indexPath) as! PostImageCell
            cell.photoImage?.image = postCell.photoImageView.image
            return cell
        }
        
        else if( indexPath.row == (self.cell_total_count-1) ){
            let cell = tableView.dequeueReusableCellWithIdentifier("submitCell", forIndexPath: indexPath) as! submitCell
            cell.delegate = self
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! commentCell
            
            let commentKeys = [String] (comments.keys)
            if (commentKeys.count > 0) {
                
                let key = commentKeys[ Int(indexPath.row-1) ] as! String
                
                cell.content?.text = comments[key]!["message"] as! String
                
                let date = NSDate(timeIntervalSince1970: (comments[key]!["publishDate"] as! Double)/1000 )
                let dayTimePeriodFormatter = NSDateFormatter()
                dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let date_str = dayTimePeriodFormatter.stringFromDate(date)
                cell.timeLabel?.text = date_str as? String
            }
            
            return cell
        }
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if( indexPath.row == 0 ){
            return 300
        }else{
            
            return 44
        }
    }
    
    
    func submitBtnClick(rowCell: submitCell) {
        let text = rowCell.submitTextField?.text!
        
        if( text == "" ){
            print("text field is empty.")
            return
        }
        
        if let currentUser = FIRAuth.auth()?.currentUser,
            message = rowCell.submitTextField?.text! {
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
            
            rowCell.submitTextField.text = ""
            self.tableView.reloadData()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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
