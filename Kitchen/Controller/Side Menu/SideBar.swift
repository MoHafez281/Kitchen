//
//  SideBar.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 1/12/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import SideMenuSwift
import SVProgressHUD
import Alamofire
import SwiftyJSON
import ObjectMapper

class SideBar: UIViewController {

    var userPoints : Int = 0
    
    @IBOutlet weak var leftConst: NSLayoutConstraint!
    @IBOutlet weak var pointsNameLabel: UILabel!
    @IBOutlet weak var pointsView: UIView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var myOrdersButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var termsAndConditionsButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var settingsImage: UIImageView!
    @IBOutlet weak var termsAndConditionsImage: UIImageView!
    @IBOutlet weak var logOutImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftConst.constant = self.view.frame.width / 3
        
        if(User.shared.isRegistered()){
            self.logOutButton.setTitle("Logout", for: .normal)
        } else {

            self.profileButton.setTitle("Register", for: .normal)
            self.favoritesButton.setTitle("Login", for: .normal)
            self.myOrdersButton.setTitle("Terms & Conditions", for: .normal)
            self.settingsButton.isHidden = true
            self.settingsImage.isHidden = true
            self.termsAndConditionsButton.isHidden = true
            self.termsAndConditionsImage.isHidden = true
            self.logOutButton.isHidden = true
            self.logOutImage.isHidden = true
            self.pointsNameLabel.isHidden = true
            self.pointsView.isHidden = true
        }
        getUserName()
        getPoints()
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        if(User.shared.isRegistered()){
            
            SVProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                User.shared.logout()
                User.shared.saveData()
                appDelegate.setRoot(storyBoard: .main, vc: .login)
            }

        } else {
        appDelegate.setRoot(storyBoard: .main, vc: .login)
        }
    }
    

    
//    @IBAction func homeButtonClicked(_ sender: UIButton) {
//        appDelegate.setRoot(storyBoard: .main, vc: .home)
//    }
    
    @IBAction func FavButtonClicked(_ sender: UIButton) {

        if(User.shared.isRegistered()){
            performSegue(withIdentifier: "goToFavorites", sender: self)
        } else {
            appDelegate.setRoot(storyBoard: .main, vc: .login)
        }
      }
    
    @IBAction func profileButtonClicked(_ sender: UIButton) {
        
        if(User.shared.isRegistered()){
            performSegue(withIdentifier: "goToProfile", sender: self)

        } else {
            performSegue(withIdentifier: "goToRegister", sender: self)
        }
    }
    
    @IBAction func myOrdersButtonClicked(_ sender: UIButton) {
        if(User.shared.isRegistered()){
            performSegue(withIdentifier: "goToMyOrders", sender: self)
        } else {
            performSegue(withIdentifier: "goToTermsAndConditions", sender: self)
        }
    }
    
    @IBAction func settingsButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSettings", sender: self)
    }
    
    @IBAction func termsButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "goToTermsAndConditions", sender: self)
        
    }
    
    func getUserName() {
    
        DispatchQueue.main.async {
            
            let params  = ["user_id" : User.shared.id ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .getProfile, parameters: params) { (JSON, error) -> Void in
                
                if(error != nil) {
                    
                    self.dismissSVProgress()
                 //   self.displayAlertMessage(title: "Error", messageToDisplay: "Connection Error")
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let profileResponse = jsonDict!["error"]
                    let profileMessage = jsonDict?["message"]
                    
                    if (profileResponse as? Int == 1) {
                        
                        if(User.shared.isRegistered()) {
                            
                          self.dismissSVProgress()
                          self.displayAlertMessage(title: "Error", messageToDisplay: profileMessage as! String)
                            
                          } else {
                            
                              self.usernameLabel.text = ""
                          }
                        
                    } else {
                        
                        if(User.shared.isRegistered()) {
                            
                            let user: User = Mapper<User>().map(JSONObject: JSON)!
                            User.shared.setIsRegister(registered: true)
                            User.shared.fillUserModel(model: user)
                            User.shared.saveData()
                            self.usernameLabel.text = "HI, \(String(User.shared.name!))"
                            
                        } else {
                            
                            self.usernameLabel.text = ""
                        }
                    }
                }
            }
        }
    }
    
    func getPoints() {
    
        DispatchQueue.main.async {
            
            let params  = ["user_id" : User.shared.id ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .getUserPoints, parameters: params) { (JSON, error) -> Void in
                
                if(error != nil){
                    
                    self.dismissSVProgress()
                    
                } else {
                        
                    let jsonDict = JSON as? NSDictionary
                    let pointsResponse = jsonDict!["error"]
                    let points = jsonDict!["points"]
                    
                    if (pointsResponse as? Int == 1) {

                        self.pointsLabel.text = "0"
                        
                    } else {

                        if User.shared.isRegistered() {
                            self.userPoints = points as! Int
                            self.pointsLabel.text = String ("\(self.userPoints)")
                            
                        } else {
                            
                            self.pointsNameLabel.isHidden = true
                            self.pointsView.isHidden = true
                        }
                    }
                }
            }
        }
    }
}
