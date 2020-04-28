//
//  LoginVC.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 12/26/18.
//  Copyright © 2018 Mohamed Hafez. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SwiftyJSON
import ObjectMapper

class LoginVC: UIViewController , UITextFieldDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.layer.cornerRadius = self.view.frame.height * 0.082 * 0.5
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToKitchen", sender: self)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        login()
    }
}

extension LoginVC {
    
    func login() {
        
        showSVProgress()
        DispatchQueue.main.async {
            
            let params  = ["email" : self.emailTF.text! ,"password" : self.passwordTF.text! ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .login, parameters: params) { (JSON, error) -> Void in
                
                if (error != nil) {
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()

                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let loginResponse = jsonDict!["error"]
                    let loginMessage = jsonDict?["message"]
                    
                    if (loginResponse as? Int == 1) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: loginMessage as! String)
                        
                    } else {
                        
                        self.dismissSVProgress()
                        let user: User = Mapper<User>().map(JSONObject: JSON)!
                        User.shared.setIsRegister(registered: true)
                        User.shared.fillUserModel(model: user)
                        User.shared.saveData()
                        self.performSegue(withIdentifier: "goToKitchen", sender: self)
                    }
                }
            }
        }
    }
}
