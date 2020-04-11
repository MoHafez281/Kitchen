//
//  RegisterVC.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 7/14/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import SVProgressHUD
import Foundation
import Alamofire
import SwiftyJSON
import ObjectMapper

class RegisterVC: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource , UITextFieldDelegate , UIAdaptivePresentationControllerDelegate{
    
    @IBOutlet weak var fullNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var mobileNumberTF: UITextField!
    @IBOutlet weak var birthdayDateTF: UITextField!
    @IBOutlet weak var jobTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var locationPicker: UITextField!
    
    
    let location = ["October", "Dokki", "Giza" , "Nasr City" , "Smart Village" , "Zamalek" , "Agouza" , "Maadi"]
    private var datePicker: UIDatePicker?

    override func viewDidLoad() {
        super.viewDidLoad()
         
        // DatePicker View
        //For setting the maximum year 2015 & minimum 1900
        var maximumYear: Date {
           return (Calendar.current as NSCalendar).date(byAdding: .year, value: -5, to: Date(), options: [])!
        }
        var minimumYear: Date {
           return (Calendar.current as NSCalendar).date(byAdding: .year, value: -120, to: Date(), options: [])!
        }
        datePicker = UIDatePicker()
        datePicker?.maximumDate = maximumYear
        datePicker?.minimumDate = minimumYear
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(RegisterVC.dateChanged(datePicker:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RegisterVC.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        birthdayDateTF.inputView = datePicker
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        locationPicker.inputView = pickerView
        
        presentationController?.delegate = self
    }
    
     // DatePiceker View
    @objc func viewTapped (gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(false)
    }
    // DatePiceker View
    @objc func dateChanged(datePicker: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        birthdayDateTF.text = dateFormatter.string(from: datePicker.date)
    }
    
    //To dismiss presentation controller and view as full view
     func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
         
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationID"), object: nil)
     }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return location.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return location[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.locationPicker.text = self.location[row]
    }
    
    @IBAction func changePlaceHolderColor(_ sender: UITextField) {
        
        if sender.tag == 0 {
            placeholder(textFields: fullNameTF, placeHolderName: "Full Name", color: .lightGray)
        } else if sender.tag == 1 {
            placeholder(textFields: emailTF, placeHolderName: "Email", color: .lightGray)
        } else if sender.tag == 2 {
            placeholder(textFields: mobileNumberTF, placeHolderName: "Mobile Number", color: .lightGray)
        } else if sender.tag == 3 {
            placeholder(textFields: birthdayDateTF, placeHolderName: "Birthday Date", color: .lightGray)
        } else if sender.tag == 4 {
            placeholder(textFields: passwordTF, placeHolderName: "Password", color: .lightGray)
        } else if sender.tag == 5 {
            placeholder(textFields: confirmPasswordTF, placeHolderName: "Confirm Password", color: .lightGray)
        } else if sender.tag == 6 {
            placeholder(textFields: locationPicker, placeHolderName: "Select Your Area", color: .lightGray)
        }
    }

    @IBAction func registerButtonClicked(_ sender: UIButton) {
        
        let providedEmailAddress = emailTF.text
        let isEmailAddressValid = isValidEmailAddress(emailAddressString: providedEmailAddress!)
        
        if fullNameTF.text == "" || emailTF.text == "" || mobileNumberTF.text == "" || birthdayDateTF.text == "" || passwordTF.text == "" || confirmPasswordTF.text == "" || locationPicker.text == "" {
            
            placeholder(textFields: fullNameTF, placeHolderName: "Full Name", color: .red)
            placeholder(textFields: emailTF, placeHolderName: "Email", color: .red)
            placeholder(textFields: mobileNumberTF, placeHolderName: "Mobile Number", color: .red)
            placeholder(textFields: birthdayDateTF, placeHolderName: "Birthday Date", color: .red)
            placeholder(textFields: passwordTF, placeHolderName: "Password", color: .red)
            placeholder(textFields: confirmPasswordTF, placeHolderName: "Confirm Password", color: .red)
            placeholder(textFields: locationPicker, placeHolderName: "Select Your Area", color: .red)
            
        } else if (emailTF.text?.count)! > 0  {
            
            if isEmailAddressValid
            {
                
                if (mobileNumberTF.text?.count)! > 11 || (mobileNumberTF.text?.count)! < 11 {
                    
                    displayAlertMessage(title: "", messageToDisplay: "Please, enter a correct mobile number")
                    
                } else if (passwordTF.text?.count)! < 8 || (passwordTF.text?.count)! > 12 {
                    
                    displayAlertMessage(title: "", messageToDisplay: "Password lenght must be minimum of 8 characters long & maximum of 12 characters long.")
                    
                } else if passwordTF.text != confirmPasswordTF.text {
                    
                    displayAlertMessage(title: "", messageToDisplay: "Entered passwords did not match.")
                    
                } else {
                    
                    if locationPicker.text == "Maadi" {

                        self.register()
                        
                    } else {
                        
                    let alert = UIAlertController(title: "Warning", message: "Available in Maadi only, Are you sure you want to register with this selected location?" , preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Yes", style: .default) { (alert) in
                        self.register()
                    }
                    let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
                    alert.addAction(cancel)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    }
                }
                                
            } else {
                
                displayAlertMessage(title: "", messageToDisplay: "Please enter a valid email.")
            }
        }
    }
}

extension RegisterVC {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == mobileNumberTF {
            let allowedCharacters = CharacterSet.decimalDigits //for digits only
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        return false
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }

        return  returnValue
    }
}

extension RegisterVC {
    
    func register() {
        
        view.isUserInteractionEnabled = false
        SVProgressHUD.show()
        DispatchQueue.main.async {
            
            let params  = ["name" : self.fullNameTF.text! , "email" : self.emailTF.text! ,"password" : self.passwordTF.text! , "phone" : self.mobileNumberTF.text! , "birthday" : self.birthdayDateTF.text! , "location" : self.locationPicker.text! , "job" : self.jobTF.text!] as [String: AnyObject]
            
            let manager = Manager()
            manager.perform(serviceName: .register , parameters: params) { (JSON, error) -> Void in
                
                if(error != nil){
                    // show error
                    self.dismissSVProgress()
                    self.noInternetConnection()

                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let registerResponse = jsonDict!["error"]
                    let registerMessage = jsonDict?["message"]
                    
                    if (registerResponse as? Int == 1) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: registerMessage as! String)
                        
                    } else {
                        
                        self.dismissSVProgress()
                        let user: User = Mapper<User>().map(JSONObject: JSON)!
                        User.shared.setIsRegister(registered: true)
                        User.shared.fillUserModel(model: user)
                        User.shared.saveData()
                        let alert = UIAlertController(title: "Register", message: "Registration Done Successfully" , preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            
                            self.dismiss(animated: true) {
                                
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationID"), object: nil)
                                self.performSegue(withIdentifier: "goToKitchen", sender: self)
                            }                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
