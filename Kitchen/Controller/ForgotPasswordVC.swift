//
//  ForgotPasswordVC.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 12/26/18.
//  Copyright © 2018 Mohamed Hafez. All rights reserved.


import UIKit
import ObjectMapper
import SVProgressHUD

class ForgotPasswordVC: UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var mobileNumberView: UIView!
    @IBOutlet weak var authCodeTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var mobileNumberTF: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mobileNumberView.isHidden = false
        self.mobileNumberTF.delegate = self
    }
    
    @IBAction func dismissForgotPasswordVC(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changePlaceHolderColor(_ sender: UITextField) {
        if sender.tag == 0 {
            placeholder(textFields: mobileNumberTF, placeHolderName: "Mobile Number", color: .lightGray)
        } else if sender.tag == 1 {
            placeholder(textFields: authCodeTF, placeHolderName: "Authentication Code", color: .lightGray)
        } else if sender.tag == 2 {
            placeholder(textFields: newPasswordTF, placeHolderName: "New Password", color: .lightGray)
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
                
        if (mobileNumberView.isHidden == false) {
            
            if ((mobileNumberTF.text?.isEmpty)!) {
                
                placeholder(textFields: mobileNumberTF, placeHolderName: "Mobile Number", color: .red)
                
            } else if (mobileNumberTF.text?.count)! > 11 || (mobileNumberTF.text?.count)! < 11 {
                
                displayAlertMessage(title: "", messageToDisplay: "Please enter a valid mobile number." )
                
            } else {
                
                let alert = UIAlertController(title: "Warning", message: "Are you sure you entered the registered mobile number?" , preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Yes", style: .default) { (alert) in
                    
                    self.forgotPassword()
                }
                let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
                alert.addAction(cancel)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            
            if ((authCodeTF.text?.isEmpty)!) || ((newPasswordTF.text?.isEmpty)!) {
                
                placeholder(textFields: authCodeTF, placeHolderName: "Authentication Code", color: .red)
                placeholder(textFields: newPasswordTF, placeHolderName: "New Password", color: .red)
                
            } else if (newPasswordTF.text?.count)! < 8 || (newPasswordTF.text?.count)! > 12 {
                
                displayAlertMessage(title: "", messageToDisplay: "Password lenght must be minimum of 8 characters long & maximum of 12 characters long." )
                
            } else {
                
                authCode()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == mobileNumberTF {
            let allowedCharacters = CharacterSet.decimalDigits //For digits only
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return false
    }
}

extension ForgotPasswordVC {
    
    func forgotPassword() {
        
        showSVProgress()
        DispatchQueue.main.async {
            
            let params  = ["phone_number" : "2\(self.mobileNumberTF.text!)" ] as [String: AnyObject]
            let customeurl = "http://52.15.188.41/cookhouse/nexmo/forgot_password.php"
            let manager = Manager()
            manager.perform(methodType: .post, useCustomeURL : true, urlStr: customeurl, serviceName: .updatePassword ,  parameters: params) { (JSON, error) -> Void in
                
                if (error != nil) {
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()

                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let forgotPasswordResponse = jsonDict!["error"]
//                  let forgotPasswordMessage = jsonDict?["status"]
                    
                    if (forgotPasswordResponse as? Int == 1) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: "Some error occurred, try again later.")
                        
                    } else {
                        
                        self.dismissSVProgress()
                        let alert = UIAlertController(title: "Forgot Password", message: "An authentication code has been sent to you via SMS" , preferredStyle: .alert)
                          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                              
                            self.mobileNumberView.isHidden = true
                            self.sendButton.setTitle("Reset", for: .normal)
                            
                          }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func authCode() {
        
        showSVProgress()
        DispatchQueue.main.async {
            
            let params  = ["password" : self.newPasswordTF.text! ,"mobile" : self.mobileNumberTF.text! , "rand": self.authCodeTF.text! ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(methodType: .post, serviceName: .forgotPasswordAuthCode ,  parameters: params) { (JSON, error) -> Void in
                
                if (error != nil) {
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let authCodeResponse = jsonDict!["error"]
                    let authCodeMessage = jsonDict?["message"]
            
                    if (authCodeResponse as? Int == 1) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: authCodeMessage as! String)
                        
                    } else {
                        
                        self.dismissSVProgress()
                        let alert = UIAlertController(title: "Forgot Password", message: "Password Changed Successfully" , preferredStyle: .alert)
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
