//
//  BetterPostsViewController.swift
//  Instogrom
//
//  Created by Paul Ku on 2016/8/1.
//  Copyright © 2016年 hpd.io. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabaseUI
import FirebaseStorage
import SDWebImage
import SVProgressHUD


class BetterPostsViewController: UITableViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, PostCellDelegate {
    
    // MARK: Properties
    var ref: FIRDatabaseReference!
    var postsRef: FIRDatabaseReference!
    var postsQuery: FIRDatabaseQuery!
    var dataSource: FirebaseTableViewDataSource!
//    let storage = FIRStorage.storage()
    var storage: FIRStorage!
//    let storageRef: = storage.referenceForURL("gs://paul-instogrom.appspot.com")
    var storageRef: FIRStorageReference!
    var imagePicker: UIImagePickerController!
    var isFirestLoad = Bool(false)
    
    // MARK: viewDidLoad Function
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        
        storage = FIRStorage.storage()
        storageRef = storage.referenceForURL("gs://paul-instogrom.appspot.com")
        
        ref = FIRDatabase.database().reference()
        postsRef = ref.child("posts")
        postsQuery = postsRef.queryOrderedByChild("postDateReversed")
        
        dataSource = FirebaseTableViewDataSource(query: postsQuery, prototypeReuseIdentifier: "PostCell", view: tableView)
        dataSource.populateCellWithBlock { cell, snapshot in
            
            let snapshot = snapshot as! FIRDataSnapshot
            let postData = snapshot.value as! [String:AnyObject]
            let cell = cell as! PostCell
            
            cell.delegate = self
            cell.emailLabel?.text = postData["email"] as? String
            
            let urlString = postData["imageURL"] as! String
            let url = NSURL(string: urlString)
            cell.photoImageView.sd_setImageWithURL(url)
            
            cell.postKey = snapshot.key as! String
            cell.imgPath = postData["imagePath"] as! String
            
            let likeRef: FIRDatabaseReference! = self.postsRef.child(snapshot.key).child("Likes")
            likeRef.observeEventType(FIRDataEventType.Value, withBlock: {
                snapshot in
                
                if let likesList = snapshot.value as? Array<String>{
                    if likesList.count > 0 {
                        cell.LikeButton.setTitle("Likes(\(likesList.count))", forState: UIControlState.Normal)
                    }
                }
                
            })
            
            let commentRef: FIRDatabaseReference! = self.postsRef.child(snapshot.key).child("Comments")
            commentRef.observeEventType(FIRDataEventType.Value, withBlock: {
                snapshot in
                
                if let commentList = snapshot.value as? Dictionary<String,AnyObject>{
                        cell.commentButton.setTitle("留言(\(commentList.count))", forState: UIControlState.Normal)
                }
                
            })
        }
        
        tableView.dataSource = dataSource
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 323
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        
        isFirestLoad = Bool(true)
        SVProgressHUD.dismiss()
    }
        
    // MARK: add Post Function
    @IBAction func addPostTapped(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let takePictureAction = UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default) { (action) in
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(takePictureAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let choosePictureAction = UIAlertAction(title: "選取照片", style: UIAlertActionStyle.Default) { (action) in

                self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(choosePictureAction)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: Image Save Function
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(pickedImage, 0.5)
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let filename = NSUUID().UUIDString
        let fullFilename = "images/" + filename + ".jpg"
        let imageRef = storageRef.child(fullFilename)
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let imageData = imageData {
            SVProgressHUD.showProgress(0)
            let uploadTask = imageRef.putData(imageData, metadata: metadata, completion: { (metadata, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    print("上傳失敗！")
                    return
                }
                
                print("上傳完成！")
                print("\(metadata?.downloadURL())")
                
                let postDate = Int(NSDate().timeIntervalSince1970 * 1000)
                
                if let currentUser = FIRAuth.auth()?.currentUser, downloadURL = metadata?.downloadURL() {
                    let photoPost = [
                        "authorUID": currentUser.uid,
                        "email": currentUser.email!,
                        "imagePath": fullFilename,
                        "imageURL": downloadURL.absoluteString,
                        "postDate": NSNumber(integer: postDate),
                        "postDateReversed": NSNumber(integer: -postDate)
                    ]
                    
                    let postRef = self.postsRef.childByAutoId()
                    postRef.updateChildValues(photoPost)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                }
            })
            
            uploadTask.observeStatus(FIRStorageTaskStatus.Progress, handler: { (snapshot) in
                if let progress = snapshot.progress {
                    SVProgressHUD.showProgress(Float(progress.fractionCompleted))
                }
            })
            
        }
    }
    // MARK: tableview cell selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: -longPress function
    func postCellLongPress(postCell: PostCell) {
        let alertController = UIAlertController(title:  nil,message: nil , preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let copyAction = UIAlertAction(title: "複製照片", style: UIAlertActionStyle.Default ) {
            action  in
            
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.image = postCell.photoImageView.image
            print("已複製照片")
        }
        alertController.addAction(copyAction)
        
        let line_url = NSURL( string: "line://" )!
        
        if UIApplication.sharedApplication().canOpenURL( line_url ){
            let sharedAction = UIAlertAction(title: "分享到LINE", style: UIAlertActionStyle.Default ) {
                action  in
                
                let pasteboard = UIPasteboard.generalPasteboard()
                pasteboard.image = postCell.photoImageView.image
                let sharedURL = NSURL( string: "line://msg/image/\(pasteboard.name)")!
                UIApplication.sharedApplication().openURL(sharedURL)
            }
            alertController.addAction(sharedAction)
        }
        
        let deleteAction = UIAlertAction(title: "刪除照片", style: UIAlertActionStyle.Destructive) {
            action in
            print("delete picture, cell key: \(postCell.postKey), imagePath: \(postCell.imgPath)")
            
            let fileRef = self.storageRef.child(postCell.imgPath)
            // Delete the file
            fileRef.deleteWithCompletion { (error) -> Void in
                if (error != nil) {
                    print( "delete file error: \(error)")
                    // Uh-oh, an error occurred!
                } else {
                    print("delete file success.")
                    let key = postCell.postKey
                    let targetRef = self.postsRef.child(key)
                    targetRef.removeValue()
                }
            }
        }
        alertController.addAction(deleteAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    // MARK: - Post Cell Tapped
    func postCellTapped(postCell: PostCell) {
        print("tapped")
    }
    
    // MARK: - Post Cell Like Button Tapped
    func postCellLikeButtonTapped(postCell: PostCell) {
        // print("postKey: \(postCell.postKey)")
        let likeRef = postsRef.child(postCell.postKey).child("Likes")
        if let currentUser = FIRAuth.auth()?.currentUser{
            likeRef.observeEventType(FIRDataEventType.Value, withBlock: {
                snapshot in
                let userID = currentUser.uid as! String
                var value = snapshot.value as? Array<String>

                let index = value.map({ (v) -> Int in
                    for (index, val) in v.enumerate() {
                        if( val == userID  ){
                            return index
                        }
                    }
                    
                    return -1
                })
                
                if index >= 0 {
                    print("uid exists.")
                } else {
                    if( value == nil ){
                        likeRef.setValue([currentUser.uid])
                    } else {
                        value? += [currentUser.uid]
                        likeRef.setValue(value)
                    }
                    print(value)
                }

                
            })
        }
        
        
    }
    
    // MARK: - Pass data to single post view
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SinglePostView" {
            let cell = (sender?.superview)?.superview as! PostCell
            let indexPath = tableView.indexPathForCell(cell)!
            print("indexPath: \(indexPath.row), postKey: \(cell.postKey)")
            let destinationVC = segue.destinationViewController as! PostTableViewController
            destinationVC.postCell = cell
        }
    }
}

