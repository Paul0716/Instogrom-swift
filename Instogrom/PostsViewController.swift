//
//  PostsViewController.swift
//  Instogrom
//
//  Created by Denny Tsai on 7/30/16.
//  Copyright © 2016 hpd.io. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabaseUI

class PostsViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    var postsRef: FIRDatabaseReference!
    
    var posts = [String: [String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        postsRef = ref.child("posts")
        
        downloadPosts()
        
    }

    func downloadPosts() {
        postsRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
            if let value = snapshot.value as? NSDictionary{
                self.posts = value as! [String : [String : AnyObject]]
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath)
        let postKeys = Array(posts.keys)
        let postKey = postKeys[indexPath.row]
        let post = posts[postKey]!
        
        cell.textLabel?.text = post["email"] as? String
        
        return cell
    }

}
