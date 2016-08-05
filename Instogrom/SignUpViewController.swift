//
//  SignUpViewController.swift
//  Instogrom
//
//  Created by Denny Tsai on 7/17/16.
//  Copyright © 2016 hpd.io. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBAction func signUpTapped(sender: AnyObject) {
        
        if let email = emailField.text, password = passwordField.text, confirmPassword = confirmPasswordField.text {
            
            guard email != "" && password != "" && confirmPassword != "" else {
                print("輸入錯誤")
                return
            }
            
            guard password == confirmPassword else {
                print("兩次輸入密碼不一樣")
                return
            }
            
            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
                if let error = error {
                    print("\(error)")
                    return
                }
                
                if let user = user {
                    print("使用者 \(user.email) 登入！")
                }
            })
        }
        
        
        
    }
    
    @IBAction func backToLoginTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
















