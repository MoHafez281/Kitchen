//
//  ForgetPasswordViewController.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 12/26/18.
//  Copyright © 2018 Mohamed Hafez. All rights reserved.
//

import UIKit
import ObjectMapper
import SVProgressHUD

class ForgetPasswordViewController: UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var mobileNumberView: UIView!
    @IBOutlet weak var authCodeTF: UITextField!
    @IBOutlet weak var enterNewPasswordTF: UITextField!
    @IBOutlet weak var enterMobileNumber: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mobileNumberView.isHidden = false
        self.enterMobileNumber.delegate = self
        
    }
    
    @IBAction func dismissClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        
        self.view.isUserInteractionEnabled = false
        
        if(mobileNumberView.isHidden == false) {
            
            if((enterMobileNumber.text?.isEmpty)!) {
                
                displayAlertMessage(title: "", messageToDisplay: "Please, Enter your phone number.")
                dismissSVProgress()
                
            } else if (enterMobileNumber.text?.count)! > 11 || (enterMobileNumber.text?.count)! < 11 {
                
                displayAlertMessage(title: "", messageToDisplay: "Please, enter a correct mobile number" )
                dismissSVProgress()
                
            } else {
                
                let alert = UIAlertController(title: "", message: "Are you sure you entered the registered mobile number?" , preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Yes", style: .default) { (alert) in
                    self.forgotPassword()
                }
                let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
                alert.addAction(cancel)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                dismissSVProgress()
            }
            
        } else {
            
            if((authCodeTF.text?.isEmpty)!){
                displayAlertMessage(title: "", messageToDisplay: "Please, Enter the authentication code you recieved." )
                dismissSVProgress()
            } else if ((enterNewPasswordTF.text?.isEmpty)!) {
                displayAlertMessage(title: "", messageToDisplay: "Please, enter your new password" )
                dismissSVProgress()
            } else if (enterNewPasswordTF.text?.count)! < 8 || (enterNewPasswordTF.text?.count)! > 12  {
                displayAlertMessage(title: "", messageToDisplay: "Password lenght must be minimum of 8 characters long & maximum of 12 characters long." )
                dismissSVProgress()
            } else {
                authCode()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == enterMobileNumber {
            let allowedCharacters = CharacterSet.decimalDigits //for digits only
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        return false
    }
}

extension ForgetPasswordViewController {
    
    func forgotPassword() {
        
        SVProgressHUD.show()
        DispatchQueue.main.async {
            
            let params  = ["phone_number" : "2\(self.enterMobileNumber.text!)" ] as [String: AnyObject]
            let customeurl = "http://52.15.188.41/cookhouse/nexmo/forgot_password.php"
            let manager = Manager()
            manager.perform(methodType: .post, useCustomeURL : true, urlStr: customeurl, serviceName: .updatePassword ,  parameters: params) { (JSON, error) -> Void in
                
                if(error != nil){
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()

                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let forgotPasswordResponse = jsonDict!["error"]
//                  let forgotPasswordMessage = jsonDict?["message"]
                    
                    if (forgotPasswordResponse as? Int == 1) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: "Some error occurred")
                        
                    } else {
                        
                        self.dismissSVProgress()
                        self.mobileNumberView.isHidden = true
                        self.sendButton.setTitle("Reset", for: .normal)
                        
                    }
                }
            }
        }
    }
    
    func authCode() {
        
        SVProgressHUD.show()
        DispatchQueue.main.async {
            
            let params  = ["password" : self.enterNewPasswordTF.text! ,"mobile" : self.enterMobileNumber.text! , "rand": self.authCodeTF.text! ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(methodType: .post, serviceName: .forgotPasswordAuthCode ,  parameters: params) { (JSON, error) -> Void in
                
                if(error != nil){
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let authCodeResponse = jsonDict!["error"]
                    let authCodeMessage = jsonDict?["message"]
            
                    if (authCodeResponse as? Int == 1) {
                        self.dismissSVProgress()
                       // self.displayAlertMessage(title: "Error", messageToDisplay: authCodeMessage as! String)
                        self.displayAlertMessage(title: "Error", messageToDisplay: "Some error occurred")
                        
                    } else {
                        
                        self.dismissSVProgress()
                        self.dismiss(animated: true)
                        
                    }
                }
            }
        }
    }
}
