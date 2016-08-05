//
//  FeedViewController.swift
//  Instogrom
//
//  Created by Denny Tsai on 7/23/16.
//  Copyright © 2016 hpd.io. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref: FIRDatabaseReference!
    var testRef: FIRDatabaseReference!
    var postsRef: FIRDatabaseReference!
    
    var imagePicker: UIImagePickerController!
    @IBOutlet weak var pickerImageView: UIImageView!
    
    override func viewDidLoad() {
        print("viewDidLoad FeedViewController")
        
        ref = FIRDatabase.database().reference()
        testRef = ref.child("test")
        postsRef = ref.child("posts")
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }

    @IBAction func logoutTapped(sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
    }
    
    @IBAction func addTapped(sender: AnyObject) {
        let childRef = testRef.childByAutoId()
        childRef.updateChildValues(["name": "Hello", "age": 20])
    }
    
    @IBAction func readDataTapped(sender: AnyObject) {
        testRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let values = snapshot.value as! [String: AnyObject]
            
            print("\(values)")
        })
    }
    
    @IBAction func addPhotoTapped(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let takePictureAction = UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default) { (action) in
                print("我要拍照")
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(takePictureAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let choosePictureAction = UIAlertAction(title: "選取照片", style: UIAlertActionStyle.Default) { (action) in
                print("我要選照片")
                
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(choosePictureAction)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("已選照片")
        
        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        pickerImageView.image = pickedImage
        
        dismissViewControllerAnimated(true, completion: nil)
        
        let imageData = UIImageJPEGRepresentation(pickedImage, 0.5)
        
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        
        let filename = NSUUID().UUIDString
        let fullFilename = "images/" + filename + ".jpg"
        
        print(fullFilename)
        
        let imageRef = storageRef.child(fullFilename)
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let imageData = imageData {
            let uploadTask = imageRef.putData(imageData, metadata: metadata, completion: { (metadata, error) in
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
                    ]
                    
                    let postRef = self.postsRef.childByAutoId()
                    postRef.updateChildValues(photoPost)
                }
            })
            
            uploadTask.observeStatus(FIRStorageTaskStatus.Progress, handler: { (snapshot) in
                    if let progress = snapshot.progress {
                        print("\(progress.fractionCompleted)")
                    }
                })
        
        }
        
    }
    
}

























