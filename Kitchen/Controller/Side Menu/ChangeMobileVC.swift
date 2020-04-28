//
//  ChangePhoneVC.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 4/6/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import ObjectMapper
import SVProgressHUD

class ChangeMobileVC: UIViewController , UITextFieldDelegate {
    
    @IBOutlet weak var authCodeView: UIView!
    @IBOutlet weak var authCodeTF: UITextField!
    @IBOutlet weak var selectPhoneTFHeight: NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var newMobileNumberTF: UITextField!
    @IBOutlet weak var oldMobileNumberTF: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    
        override func viewDidLoad() {
        super.viewDidLoad()
    
        oldMobileNumberTF.text = User.shared.phone
        oldMobileNumberTF.isEnabled = false
        
        self.newMobileNumberTF.delegate = self
        self.authCodeTF.delegate = self
    }
    
    @IBAction func dismissChangeMobileVC(_ sender: UIButton) {
         self.dismiss(animated: true, completion: nil)
     }
    
    @IBAction func changePlaceHolderColor(_ sender: UITextField) {
        
        if sender.tag == 0 {
            placeholder(textFields: newMobileNumberTF, placeHolderName: "New Mobile Number", color: .lightGray)
        } else if sender.tag == 1 {
            placeholder(textFields: authCodeTF, placeHolderName: "Authentication Code", color: .lightGray)
        }
    }
 
    @IBAction func updateButtonClicked(_ sender: UIButton) {
        
        if (authCodeView.isHidden) {
            
            if ((newMobileNumberTF.text?.isEmpty)!) {
                
                placeholder(textFields: newMobileNumberTF, placeHolderName: "New Mobile Number", color: .red)
                
            } else if (newMobileNumberTF.text == User.shared.phone) {
                
                displayAlertMessage(title: "Error", messageToDisplay: "You entered the old mobile number, Please enter a new one.")
                
            } else if (newMobileNumberTF.text?.count)! > 11 || (newMobileNumberTF.text?.count)! < 11 {
                
                displayAlertMessage(title: "", messageToDisplay: "Please enter a valid mobile number." )
                
            } else {
                
                self.changePhone()
            }
        
        } else {
            
            if ((authCodeTF.text?.isEmpty)!) {
                
                placeholder(textFields: authCodeTF, placeHolderName: "Authentication Code", color: .red)
                
            } else {
                
                authCode()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == newMobileNumberTF || textField == authCodeTF {
            let allowedCharacters = CharacterSet.decimalDigits //for digits only
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        return false
    }
}

extension ChangeMobileVC {
    
    func changePhone() {
        
        showSVProgress()
        DispatchQueue.main.async {
            
            let params  = ["user_id" : User.shared.id! ,"phone_number" : "2\(self.newMobileNumberTF.text!)" ] as [String: AnyObject]
            let customeurl = "http://52.15.188.41/cookhouse/nexmo/phone_update.php"
            let manager = Manager()
            manager.perform(methodType: .post, useCustomeURL : true, urlStr: customeurl, serviceName: .updatePassword ,  parameters: params) { (JSON, error) -> Void in
                
                if (error != nil) {
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()
  
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let changeMobileResponse = jsonDict!["error"]
//                  let changeMobileMessage = jsonDict?["message"]
                    
                    if (changeMobileResponse as? Int == 1) {
                       
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: "Some error occurred, try again later.")

                    } else {
                        
                        self.dismissSVProgress()
                        let alert = UIAlertController(title: "Change Mobile Number", message: "An authentication code has been sent to you via SMS." , preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                                      
                                self.authCodeView.isHidden = false
                                self.updateButton.setTitle("Send", for: .normal)
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
            
            let params  = ["user_id" : User.shared.id! ,"phone" : self.newMobileNumberTF.text!, "rand": self.authCodeTF.text! ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(methodType: .post, serviceName: .authCode ,  parameters: params) { (JSON, error) -> Void in
                
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
                        let alert = UIAlertController(title: "Change Mobile Number", message: "Mobile Number Changed Successfully" , preferredStyle: .alert)
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
