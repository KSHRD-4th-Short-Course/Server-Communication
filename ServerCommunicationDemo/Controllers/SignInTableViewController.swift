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
        
        if (UserDefaults.standard.string(forKey: "UserID") != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateInitialViewController()
            self.present(viewController!, animated: false, completion: nil)
        }
    }
    
    // TODO: SignIn IBAction
    @IBAction func signInAction(_ sender: Any) {
        let activityData = ActivityData()
        
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        // Create dictionary as request paramater
        let paramaters = ["email": emailTextField.text!, "password": passwordTextField.text!]
        
        UserService.shared.signin(paramaters: paramaters) { (response, error) in
            // show other NVActivityIndicator
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            // check error
            if let error = error { SCLAlertView().showError("Error", subTitle: error.localizedDescription); return }
            
            // check response from server
            if let value = response?.result.value {
                let json = JSON(value)
                
                if let code = json["code"].int, code == 2222, let id = json["data"]["id"].int {
                    UserDefaults.standard.set("\(id)", forKey: "UserID")
                }else {
                    SCLAlertView().showError("Error", subTitle: json["message"].stringValue)
                    return
                }
            }else {
                SCLAlertView().showError("Error", subTitle: "Server error")
                return
            }
            
            // Create storyboard by name
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Create view controller object by InitialViewController
            // let vc = storyboard.instantiateInitialViewController()
            
            // Create view controller object by ViewController Identifier
            let vc = storyboard.instantiateViewController(withIdentifier: "RootStorybaordID")
            
            // open view controller
            self.present(vc, animated: true, completion: nil)
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
                        print(token.description)
                        self.fetchProfile()
                    }
                }
            }
        })
    }
    
    // Get Profile
    func fetchProfile() {
        print("fetch profile")
        let activityData = ActivityData()
        
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        // Create facebook graph with fields
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"email, first_name, last_name, gender, picture.type(large), birthday, photos"]).start { (connection, result, error) in
            
            // check error
            // check error
            if let error = error {
                // show other NVActivityIndicator
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                return
            }
            
            let json = JSON(result!)

            let paramaters = [
                "email": json["email"].string ?? json["id"].stringValue,
                "name": "\(json["first_name"].stringValue) \(json["last_name"].stringValue)",
                "gender": json["gender"].stringValue == "male" ? "m" : "f",
                "photoUrl": json["picture"]["data"]["url"].string ?? "",
                "facebook_id": json["id"].stringValue
                ]
            
            UserService.shared.signinWithFacebook(paramaters: paramaters, completion: { (response, error) in
                // show other NVActivityIndicator
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                // check error
                if let error = error { SCLAlertView().showError("Error", subTitle: error.localizedDescription); return }
                
                if let value = response?.result.value {
                    let json = JSON(value)
                    
                    if let code = json["code"].int, code == 2222, let id = json["data"]["id"].int {
                        UserDefaults.standard.set("\(id)", forKey: "UserID")
                    }else {
                        SCLAlertView().showError("Error", subTitle: json["message"].stringValue)
                        return
                    }
                }else {
                    SCLAlertView().showError("Error", subTitle: "Server error")
                    return
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateInitialViewController()
                self.present(viewController!, animated: true, completion: nil)
            })
        }
    }
}
