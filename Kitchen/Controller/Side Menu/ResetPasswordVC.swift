//
//  ResetPasswordVC.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 4/6/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import ObjectMapper
import SVProgressHUD

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var currtentPasswordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func dismissResetPasswordVC(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func changePlaceHolderColor(_ sender: UITextField) {
        if sender.tag == 0 {
            placeholder(textFields: currtentPasswordTF, placeHolderName: "Current Password", color: .lightGray)
        } else if sender.tag == 1 {
            placeholder(textFields: newPasswordTF, placeHolderName: "New Password", color: .lightGray)
        } else if sender.tag == 2 {
            placeholder(textFields: confirmPasswordTF, placeHolderName: "Confirm New Password", color: .lightGray)
        }
    }
    
    @IBAction func confirmResetPasswordPressed(_ sender: UIButton) {
        
        if currtentPasswordTF.text == "" || newPasswordTF.text == "" || confirmPasswordTF.text == "" {
            
            placeholder(textFields: currtentPasswordTF, placeHolderName: "Current Password", color: .red)
            placeholder(textFields: newPasswordTF, placeHolderName: "New Password", color: .red)
            placeholder(textFields: confirmPasswordTF, placeHolderName: "Confirm New Password", color: .red)
            
        } else if (newPasswordTF.text?.count)! < 8 || (newPasswordTF.text?.count)! > 12 {
            
            displayAlertMessage(title: "", messageToDisplay: "Password lenght must be minimum of 8 characters long & maximum of 12 characters long.")
            
        } else if newPasswordTF.text != confirmPasswordTF.text {
            
            displayAlertMessage(title: "", messageToDisplay: "Entered passwords did not match.")
            
        } else {
            
            resetPassword()
        }
    }
}

extension ResetPasswordVC {
    
    func resetPassword() {
        
        showSVProgress()
        DispatchQueue.main.async {
            
            var customeurl = hostName + "update_password/\(User.shared.id!)/\(self.currtentPasswordTF.text!)/\(self.newPasswordTF.text!)"
            customeurl = customeurl.replacingOccurrences(of: " ", with: "%20")
            
            let manager = Manager()
            manager.perform(methodType: .put, useCustomeURL : true, urlStr: customeurl, serviceName: .updatePassword ,  parameters: nil) { (JSON, error) -> Void in
                
                if(error != nil) {

                    self.dismissSVProgress()
                    self.noInternetConnection()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let resetPasswordResponse = jsonDict!["error"]
                    let resetPasswordMessage = jsonDict?["message"]
                    
                    if (resetPasswordResponse as? Int == 1) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: resetPasswordMessage as! String)
                        
                    } else {
                    
                        self.dismissSVProgress()
                        let alert = UIAlertController(title: "Reset Password", message: "Password Updated Successfully." , preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                                      
                            self.dismiss(animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
