//
//  LoginPopup.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 3/30/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SwiftyJSON
import ObjectMapper

class LoginPopup: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reload the view after checking the network connectivity and it is working
        NotificationCenter.default.addObserver(self, selector: #selector(CollectionViewController.functionName), name:NSNotification.Name(rawValue: "NotificationID"), object: nil)
    }
    
    //Reload the view after checking the network connectivity and it is working
    @objc func functionName() {
        login()
    }
    
    @IBAction func dismissPopup(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "goToRegister", sender: self)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        login()
    }
}

extension LoginPopup {
    
    func login() {
        
        self.view.isUserInteractionEnabled = false
        SVProgressHUD.show()
        DispatchQueue.main.async {
            
            let params  = ["email" : self.emailTextField.text! ,"password" : self.passwordTextField.text! ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .login, parameters: params) { (JSON, error) -> Void in
                
                if(error != nil){
                    
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
