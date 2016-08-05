//
//  ProfileController.swift
//  Instogrom
//
//  Created by Paul Ku on 2016/8/2.
//  Copyright © 2016年 hpd.io. All rights reserved.
//

import UIKit
import JDSwiftAvatarProgress
import Firebase
import SVProgressHUD

class ProfileController: UITableViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var avatarImgView: JDAvatarProgress!
    @IBOutlet weak var accountLabel: UILabel!
    
    var imagePicker: UIImagePickerController!
    var ref: FIRDatabaseReference!
    var userRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Firebase init
        ref = FIRDatabase.database().reference()
        userRef = ref.child("users")
        
        // imagePicker delegate
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        
        if let user = FIRAuth.auth()?.currentUser{
            accountLabel.text = user.email!
            let userRef = self.userRef.child("\(user.uid)")
            userRef.observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
                let profile = snapshot.value as! [String : AnyObject]
                let avatorURL = profile["avatorURL"] as? String
                self.avatarImgView.setImageWithURL(NSURL(string: avatorURL! )!)
            })
        }
        
        self.avatarImgView.image = UIImage(named: "empty_avatar")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: change avator function
    @IBAction func changeAvator(sender: AnyObject) {
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
        let fullFilename = "profile/" + filename + ".jpg"
        
        print(fullFilename)
        
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
                    let userProfile = [
                        "authorUID": currentUser.uid,
                        "email": currentUser.email!,
                        "avatorPath": fullFilename,
                        "avatorURL": downloadURL.absoluteString,
                        "updateDate": NSNumber(integer: postDate),
                    ]
                    let userRef = self.userRef.child("\(currentUser.uid)")
                    userRef.updateChildValues(userProfile)
                    
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
    
    @IBAction func userSignout(sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
    }
    
}




