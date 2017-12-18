//
//  SignInTableViewController.swift
//  ServerCommunicationDemo
//
//  Created by Kokpheng on 11/10/16.
//  Copyright © 2016 Kokpheng. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import SCLAlertView
import FBSDKCoreKit
import FBSDKLoginKit

class SignInTableViewController: UITableViewController {
    
    // Outlet
    @IBOutlet var emailTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ((FBSDKAccessToken.current()) != nil) {
            // User is logged in, do work such as go to next view controller.
        }
    }
    
    // TODO: SignIn IBAction
    @IBAction func signInAction(_ sender: Any) {
        let activityData = ActivityData()
        
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        // Create dictionary as request paramater
        let paramaters = ["email": emailTextField.text!, "password": passwordTextField.text!]
        
        let service = UserService()
        service.signin(paramaters: paramaters) { (response, error) in
            // show other NVActivityIndicator
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            // check error
            if let error = error { SCLAlertView().showError("Error", subTitle: error.localizedDescription); return }
            
            // check response from server
            if let value = response?.result.value {
                
                let json = JSON(value)
                print("JSON: \(json)")
                
                if let code = json["code"].int {
                    if code == 2222 {
                        // Create storyboard by name
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        // Create view controller object by InitialViewController
                        // let vc = storyboard.instantiateInitialViewController()
                        
                        // Create view controller object by ViewController Identifier
                        let vc = storyboard.instantiateViewController(withIdentifier: "RootStorybaordID")
                        
                        // open view controller
                        self.present(vc, animated: true, completion: nil)
                    }else {
                        SCLAlertView().showError("Error", subTitle: json["message"].stringValue)
                    }
                }
            }
        }
    }
    
    // MARK: - Login with Facebook
    @IBAction func loginWithFacebook(_ sender: Any) {
        
        // Init Facebook SDK Manager
        let loginManager = FBSDKLoginManager()
        let parameters = ["email", "public_profile"]
        // Request login
        loginManager.logIn(withReadPermissions: parameters, from: self, handler: { (result, error) in
            if let error = error {
                // error happen
                print("Failed to start graph request: \(error.localizedDescription)")
                return
            } else if result!.isCancelled {
                print("FBLogin cancelled")
            } else {
                // Logged in
                if (result?.grantedPermissions.contains("public_profile"))!{
                    if let token = FBSDKAccessToken.current(){
                        print(token.tokenString! as Any)
                        self.fetchProfile()
                    }
                }
            }
        })
    }
    
    // Get Profile
    func fetchProfile() {
        print("fetch profile")
        
        // Create facebook graph with fields
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id, name, email"]).start { (connection, result, error) in
            
            // check error
            if let error = error  {
                // error happen
                print("Failed to start graph request: \(error.localizedDescription)")
                return
            }
            print(result as Any)
        }
    }
}
