//
//  LoginViewController.swift
//  Instogrom
//
//  Created by Denny Tsai on 7/23/16.
//  Copyright © 2016 hpd.io. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NSNotificationCenter.defaultCenter()
        
        center.addObserverForName("InstogromUserDidLogIn", object: nil, queue: nil) { (notification) in
            print("user logged in from loginVC")
        }
        
        center.addObserverForName("InstogromUserDidLogOut", object: nil, queue: nil) { (notification) in
            print("user logged out from loginVC")
        }
    }
    
    @IBAction func loginTapped(sender: AnyObject) {
        if let email = emailTextField.text, password = passwordTextField.text {
            if email == "" || password == "" {
                print("E-mail或密碼沒輸入")
                return
            }
            
            FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
                if let error = error {
                    print("登入失敗: \(error)")
                    return
                }
            })
        }
    }
    
    @IBAction func adskfjasdf(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func returnToLogin(segue: UIStoryboardSegue) {
        if segue.identifier == "fromSignUpToLogin" {
            emailTextField.text = ""
            passwordTextField.text = ""
            
        }
        
    }
    
    @IBAction func logoutTapped(sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
    }
    
}









