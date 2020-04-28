//
//  LoginPopupVC.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 3/30/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SwiftyJSON
import ObjectMapper

class LoginPopupVC: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RegisterVC.dismissBackButtonRegisterVC = 2 //If user go to RegisterVC from LogiubPoupVC, LogiubPoupVC will appear as presenation style so this var to let back button act as dismiss else act normally
//      Dismiss LoginPopupVC after user login
        NotificationCenter.default.addObserver(self, selector: #selector(LoginPopupVC.functionName), name:NSNotification.Name(rawValue: "dismissLoginPopypVC"), object: nil)
    }
    
//  Dismiss LoginPopupVC after user login
    @objc func functionName() {
        dismissLoginPopupVC(self)
    }
    
    @IBAction func dismissLoginPopupVC(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        loginPopup()
    }
}

extension LoginPopupVC {
    
    func loginPopup() {
        
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
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
