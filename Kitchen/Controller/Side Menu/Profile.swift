    //
    //  Profile.swift
    //  Kitchen
    //
    //  Created by Mohamed Hafez on 2/22/19.
    //  Copyright © 2019 Mohamed Hafez. All rights reserved.
    //
    
    import UIKit
    import SideMenuSwift
    import Alamofire
    import SwiftyJSON
    import ObjectMapper
    import SVProgressHUD
    
    class Profile: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource, UITextFieldDelegate {
        
        @IBOutlet weak var nameTextField: UITextField!
        @IBOutlet weak var emailTextField: UITextField!
        @IBOutlet weak var addressTextField: UITextField!
        @IBOutlet weak var defaultMobileNumberTextField: UITextField!
        @IBOutlet weak var birthday: UITextField!
        @IBOutlet weak var jobTextField: UITextField!
        @IBOutlet weak var locationPickerTextField: UITextField!
        @IBOutlet weak var saveButton: UIButton!
        
        let location = ["", "October", "Dokki", "Giza" , "Nasr City" , "Smart Village" , "Zamalek" , "Agouza" , "Maddi"]
        var place : String = ""
        var addressList = [AdressModel]()
        var selectedAdress : AdressModel?
        var currentTextField = UITextField()
        var pickerView = UIPickerView()
        private var datePicker: UIDatePicker?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
             NotificationCenter.default.addObserver(self, selector: #selector(CollectionViewController.functionName), name:NSNotification.Name(rawValue: "NotificationID"), object: nil)
            
//            let vc = UIViewController()
//            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
//            self.present(vc, animated: true, completion: nil)
            
            emailTextField.isEnabled = false
            defaultMobileNumberTextField.isEnabled = false
            
            // DatePiceker View
            datePicker = UIDatePicker()
            datePicker?.datePickerMode = .date
            datePicker?.addTarget(self, action: #selector(Profile.dateChanged(datePicker:)), for: .valueChanged)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Profile.viewTapped(gestureRecognizer:)))
            view.addGestureRecognizer(tapGesture)
            birthday.inputView = datePicker
            
            // get Profile { success: set lel tf}

            getProfile()
            getAddresses()
        }
        
        @objc func functionName() {

            getProfile()
            getAddresses()
        }
    
        // DatePiceker View
        @objc func viewTapped (gestureRecognizer: UITapGestureRecognizer) {
            view.endEditing(true)
        }
        // DatePiceker View
        @objc func dateChanged(datePicker: UIDatePicker) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            birthday.text = dateFormatter.string(from: datePicker.date)
            view.endEditing(true)
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if currentTextField == locationPickerTextField {
                return location.count
            } else if currentTextField == addressTextField {
                return addressList.count
            } else {
                return 0
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if currentTextField == locationPickerTextField {
                return location[row]
            } else if currentTextField == addressTextField  {
               return addressList[row].addressName
            } else {
              return ""
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if currentTextField == locationPickerTextField {
                locationPickerTextField.text = location[row]
                self.view.endEditing(true)
            } else if currentTextField == addressTextField {
                addressTextField.text = addressList[row].addressName
                selectedAdress = addressList[row]
                self.view.endEditing(true)
            }
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            self.pickerView.delegate = self
            self.pickerView.dataSource = self
            currentTextField = textField
            if currentTextField == locationPickerTextField {
                currentTextField.inputView = pickerView
            } else if currentTextField == addressTextField {
                currentTextField.inputView = pickerView
            }
        }
        
        @IBAction func sideBarTapped(_ sender: Any) {
            self.sideMenuController?.revealMenu()
        }
        
        @IBAction func saveButtonPressed(_ sender: UIButton) {
            
            SVProgressHUD.show()
            self.view.isUserInteractionEnabled = false
            updateProfile()
        }
        
        func getProfile() {
        
            DispatchQueue.main.async {
                
                let params  = ["user_id" : User.shared.id ] as [String: AnyObject]
                let manager = Manager()
                manager.perform(serviceName: .getProfile, parameters: params) { (JSON, error) -> Void in
                    
                    if(error != nil){
                        
                        self.dismissSVProgress()
                        self.noInternetConnection()
                        
                    } else {
                        
                        let jsonDict = JSON as? NSDictionary
                        let profileResponse = jsonDict!["error"]
                        let profileMessage = jsonDict?["message"]
                        
                        if (profileResponse as? Int == 1) {
                            
                            self.dismissSVProgress()
                            self.displayAlertMessage(title: "Error", messageToDisplay: profileMessage as! String)
                            
                        } else {
                            
                            let addressErrorResponse = jsonDict!["addresses_error"]
                            let addressErrorMessage = jsonDict!["error_msg"]
                            
                            if (addressErrorResponse as? Int == 1) {
                                
                                self.dismissSVProgress()
                                self.displayAlertMessage(title: "Error", messageToDisplay: addressErrorMessage as! String)
                            }
                            
                            let user: User = Mapper<User>().map(JSONObject: JSON)!
                            User.shared.setIsRegister(registered: true)
                            User.shared.fillUserModel(model: user)
                            User.shared.saveData()
                            self.nameTextField.text = User.shared.name
                            self.emailTextField.text = User.shared.email
                            self.defaultMobileNumberTextField.text = User.shared.phone
                            self.birthday.text = User.shared.birthday
                            self.jobTextField.text = User.shared.job
                            self.addressTextField.text = User.shared.address
                            self.locationPickerTextField.text = User.shared.location
                        }
                    }
                }
            }
        }
        
        func updateProfile() {

            DispatchQueue.main.async {
                
                let params  = ["id" : User.shared.id! , "name" : self.nameTextField.text! , "add_id" : self.selectedAdress?.id as Any , "date_of_birth" : self.birthday.text! , "location" : self.locationPickerTextField.text! , "job" : self.jobTextField.text!] as [String: AnyObject]
                
                let manager = Manager()
                manager.perform(serviceName: .updateUser , parameters: params) { (JSON, error) -> Void in
                    
                    if(error != nil) {
                        
                        self.dismissSVProgress()
                        self.noInternetConnection()
                        
                    } else {
                        
                        let jsonDict = JSON as? NSDictionary
                        let updateProfileResponse = jsonDict!["error"]
                        let updateProfileMessage = jsonDict?["message"]
                        
                        if (updateProfileResponse as? Int == 1) {
                            
                            self.dismissSVProgress()
                            self.displayAlertMessage(title: "Error", messageToDisplay: updateProfileMessage as! String)
                            
                        } else {
                            
                            self.dismissSVProgress()
                            self.displayAlertMessage(title: "", messageToDisplay: "Your profile has been updated successfully")
                            appDelegate.setRoot(storyBoard: .main, vc: .home)
                        }
                    }
                }
            }
        }
        
        func getAddresses(){
            
            DispatchQueue.main.async {
            
                let params  = ["user_id" : User.shared.id ] as [String: AnyObject]
                let manager = Manager()
                manager.perform(serviceName: .getAddress, parameters: params) { (JSON, error) -> Void in
                    
                    if(error != nil) {
                        
                        self.dismissSVProgress()
                        self.noInternetConnection()
                        
                    } else {
                        
                        let jsonDict = JSON as? NSDictionary
                        let getAddressesResponse = jsonDict!["error"]
                        let getAdressesMessage = jsonDict!["error_msg"]
                        
                        if(getAddressesResponse as? Int == 1 ) {
                            
                            self.dismissSVProgress()
                            self.displayAlertMessage(title: "Error", messageToDisplay: getAdressesMessage as! String)
                            
                        } else {
                            
                            self.dismissSVProgress()
                            let address = jsonDict!["addresses"]
                            self.addressList = Mapper<AdressModel>().mapArray(JSONObject: address)!
                            
                            if(self.addressList.count > 0) {
                                
                                self.selectedAdress = self.addressList[0]
                                self.addressTextField.text = self.addressList[0].addressName
                            }
                        }
                    }
                }
            }
        }
    }
