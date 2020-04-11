//
//  ChangePhone.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 4/6/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import ObjectMapper
import SVProgressHUD

class ChangePhone: UIViewController , UITextFieldDelegate {
    
    @IBOutlet weak var authCodeView: UIView!
    @IBOutlet weak var authCodeTF: UITextField!
    @IBOutlet weak var selectPhoneTFHeight: NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var enterPhoneTF: UITextField!
    @IBOutlet weak var selectPhoneTF: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectPhoneTF.text = User.shared.phone
        selectPhoneTF.isEnabled = false
        
        self.enterPhoneTF.delegate = self
        self.authCodeTF.delegate = self
    }
    
    @IBAction func dismissClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func updateButtonClicked(_ sender: UIButton) {
        
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
        
        if(authCodeView.isHidden){
            if((enterPhoneTF.text?.isEmpty)!){
                
                displayAlertMessage(title: "Warning", messageToDisplay: "Please, Enter your new phone number.")
                dismissSVProgress()
                
            }else if (enterPhoneTF.text == User.shared.phone){
                displayAlertMessage(title: "Warning", messageToDisplay: "You entered the old Mobile Number, Please enter a new one")
                dismissSVProgress()
            } else if (enterPhoneTF.text?.count)! < 11 {
            displayAlertMessage(title: "Warning", messageToDisplay: "Your mobile number less than 11 digits")
            dismissSVProgress()
            
            } else if (enterPhoneTF.text?.count)! > 12 {
            displayAlertMessage(title: "Warning", messageToDisplay: "Your mobile number more than 11 digits")
            dismissSVProgress()
            
            } else {
                changePhone()
            }
            
        } else {
            if((authCodeTF.text?.isEmpty)!){
                displayAlertMessage(title: "Warning", messageToDisplay: "Please, Enter the authentication code you recieved." )
            } else {
                authCode()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == enterPhoneTF || textField == authCodeTF {
            let allowedCharacters = CharacterSet.decimalDigits //for digits only
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        return false
    }
    
    
}

extension ChangePhone {
    
    func changePhone() {
        
        DispatchQueue.main.async {
            
            let params  = ["user_id" : User.shared.id! ,"phone_number" : "2\(self.enterPhoneTF.text!)" ] as [String: AnyObject]
            let customeurl = "http://52.15.188.41/cookhouse/nexmo/phone_update.php"
            let manager = Manager()
            manager.perform(methodType: .post, useCustomeURL : true, urlStr: customeurl, serviceName: .updatePassword ,  parameters: params) { (JSON, error) -> Void in
                
                if(error != nil){
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()
  
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let changePhoneResponse = jsonDict!["error"]
                    let changePhoneMessage = jsonDict?["message"]
                    
                    if (changePhoneResponse as? Int == 1) {
                       
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: changePhoneMessage as! String)

                    } else {
                        
                        self.dismissSVProgress()
                        self.authCodeView.isHidden = false
                        self.updateButton.setTitle("Send", for: .normal)
                        
                    }
                }
            }
        }
    }
    
    func authCode() {
        
        DispatchQueue.main.async {
            
            let params  = ["user_id" : User.shared.id! ,"phone" : self.enterPhoneTF.text!, "rand": self.authCodeTF.text! ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(methodType: .post, serviceName: .authCode ,  parameters: params) { (JSON, error) -> Void in
                
                if(error != nil){

                    self.displayAlertMessage(title: "Error", messageToDisplay: "ConnectionError")
                    self.dismissSVProgress()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let authCodeResponse = jsonDict!["error"]
                    let authCodeMessage = jsonDict?["message"]
                    
                    if (authCodeResponse as? Int == 1) {
                    
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: authCodeMessage as! String)

                    } else {
                        
                        self.dismissSVProgress()
                        self.dismiss(animated: true)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}
