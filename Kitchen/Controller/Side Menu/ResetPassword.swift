//
//  ResetPassword.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 4/6/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import ObjectMapper
import SVProgressHUD

class ResetPassword: UIViewController {

    @IBOutlet weak var currtentPasswordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissPopup(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func confirmResetPasswordClicked(_ sender: UIButton) {
        // check that all fields have values
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
        
        if (newPasswordTF.text?.count)! < 8 {
            displayAlertMessage(title: "Error", messageToDisplay: "Your password is too short")
            dismissSVProgress()
        } else if confirmPasswordTF.text?.count != newPasswordTF.text?.count {
            displayAlertMessage(title: "Error", messageToDisplay: "Password does not match")
            dismissSVProgress()
        } else {
            resetPassword()
        }
    }
}

extension ResetPassword {
    
    func resetPassword() {
        
        DispatchQueue.main.async {
            
            var customeurl = hostName + "update_password/\(User.shared.id!)/\(self.currtentPasswordTF.text!)/\(self.newPasswordTF.text!)"
            customeurl = customeurl.replacingOccurrences(of: " ", with: "%20")
            
            let manager = Manager()
            manager.perform(methodType: .put, useCustomeURL : true, urlStr: customeurl, serviceName: .updatePassword ,  parameters: nil) { (JSON, error) -> Void in
                
                if(error != nil){
                    // show error
                    self.dismissSVProgress()
                    self.noInternetConnection()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let changePasswordResponse = jsonDict!["error"]
                    let changePasswordMessage = jsonDict?["message"]
                    
                    if (changePasswordResponse as? Int == 1) {
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: changePasswordMessage as! String)
                        
                    }
                    self.dismissSVProgress()
                    self.displayAlertMessage(title: "", messageToDisplay: "Password Updated successfully")
                    self.dismiss(animated: true)
                }
                
            }
            
        }
        
    }
    
}
