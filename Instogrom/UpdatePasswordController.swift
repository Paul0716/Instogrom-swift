//
//  UpdatePasswordController.swift
//  Instogrom
//
//  Created by Paul Ku on 2016/8/2.
//  Copyright © 2016年 hpd.io. All rights reserved.
//

import UIKit
import Firebase


class UpdatePasswordController: UIViewController {
    
    // MARK: - Properties

    @IBOutlet weak var newPWtextField: UITextField!
    @IBOutlet weak var confirmPWtextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updatePassword(sender: AnyObject) {
        
        if newPWtextField!.text == "" || confirmPWtextField!.text == "" {
            print("請輸入密碼")
            return
        }
        
        if !(newPWtextField!.text == confirmPWtextField!.text) {
            print("密碼不相同.")
            return
        }
        
        if let user = FIRAuth.auth()?.currentUser{
            user.updatePassword( self.newPWtextField.text!, completion: nil)
            navigationController?.popViewControllerAnimated(true)
        }

        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
