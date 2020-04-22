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
        
        let location = ["October", "Dokki", "Giza" , "Nasr City" , "Smart Village" , "Zamalek" , "Agouza" , "Maadi"]
        var addressList = [AdressModel]()
        var selectedAdress : AdressModel?
        var currentTextField = UITextField()
        var pickerView = UIPickerView()
        private var datePicker: UIDatePicker?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
//          Reload the view after checking the network connectivity and it is working
            NotificationCenter.default.addObserver(self, selector: #selector(Profile.functionName), name:NSNotification.Name(rawValue: "NotificationID"), object: nil)
            
            emailTextField.isEnabled = false //This field cannot be changed
            defaultMobileNumberTextField.isEnabled = false //This field cannot be changed
            
//          DatePicker View
//          For setting the maximum year 2015 & minimum 1900
            var maximumYear: Date {
                return (Calendar.current as NSCalendar).date(byAdding: .year, value: -5, to: Date(), options: [])!
            }
            var minimumYear: Date {
                return (Calendar.current as NSCalendar).date(byAdding: .year, value: -120, to: Date(), options: [])!
            }
//           DatePicker View
            datePicker = UIDatePicker()
            datePicker?.maximumDate = maximumYear
            datePicker?.minimumDate = minimumYear
            datePicker?.datePickerMode = .date
            datePicker?.addTarget(self, action: #selector(Profile.dateChanged(datePicker:)), for: .valueChanged)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Profile.viewTapped(gestureRecognizer:)))
            view.addGestureRecognizer(tapGesture)
            birthday.inputView = datePicker
            
//          get Profile { success: set lel tf}
            getProfile()
            getAddresses()
        }
//      DatePiceker View
        @objc func viewTapped (gestureRecognizer: UITapGestureRecognizer) {
            view.endEditing(false)
        }
//      DatePiceker View
        @objc func dateChanged(datePicker: UIDatePicker) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            birthday.text = dateFormatter.string(from: datePicker.date)
        }
        
//      Reload the view after checking the network connectivity and it is working
        @objc func functionName() {
            getProfile()
            getAddresses()
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
            
            if locationPickerTextField.text == User.shared.location {
                
                updateProfile()
                
            } else {
                
                if locationPickerTextField.text == "Maadi" {
                    updateProfile()
                    
                } else {
                    
                    let alert = UIAlertController(title: "Warning", message: "Available in Maadi only, Are you sure you want to register with this selected location?" , preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Yes", style: .default) { (alert) in
                    
                        self.updateProfile()
                }
                    
                    let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
                    alert.addAction(cancel)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        func getProfile() {
        
            saveButton.isEnabled = false
            showSVProgress()
            DispatchQueue.main.async {
                
                let params  = ["user_id" : User.shared.id ] as [String: AnyObject]
                let manager = Manager()
                manager.perform(serviceName: .getProfile, parameters: params) { (JSON, error) -> Void in
                    
                    if (error != nil) {
                        
                        self.dismissSVProgress()
                        self.noInternetConnection()
                        self.addressTextField.isEnabled = false
                        
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
                            self.saveButton.isEnabled = true
                        }
                    }
                }
            }
        }
        
        func updateProfile() {

            showSVProgress()
            DispatchQueue.main.async {
                
                let params  = ["id" : User.shared.id! , "name" : self.nameTextField.text! , "add_id" : self.selectedAdress?.id as Any , "date_of_birth" : self.birthday.text! , "location" : self.locationPickerTextField.text! , "job" : self.jobTextField.text!] as [String: AnyObject]
                
                let manager = Manager()
                manager.perform(serviceName: .updateUser , parameters: params) { (JSON, error) -> Void in
                    
                    if (error != nil) {
                        
                        self.dismissSVProgress()
                        self.noInternetConnection()
                        self.addressTextField.isEnabled = false
                        
                    } else {
                        
                        let jsonDict = JSON as? NSDictionary
                        let updateProfileResponse = jsonDict!["error"]
                        let updateProfileMessage = jsonDict?["message"]
                        
                        if (updateProfileResponse as? Int == 1) {
                            
                            self.dismissSVProgress()
                            self.displayAlertMessage(title: "Error", messageToDisplay: updateProfileMessage as! String)
                            
                        } else {
                            
                            self.dismissSVProgress()
                            let alert = UIAlertController(title: "", message: "Your profile has been updated successfully" , preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                                
                                SideBar.checkVisiableView = 1 //To Check which SideMenuVC is visiable now, so to make HomeVC visiable now
                                self.performSegue(withIdentifier: "goToKitchen", sender: self)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        
        func getAddresses() {
            
            showSVProgress()
            DispatchQueue.main.async {
            
                let params  = ["user_id" : User.shared.id ] as [String: AnyObject]
                let manager = Manager()
                manager.perform(serviceName: .getAddress, parameters: params) { (JSON, error) -> Void in
                    
                    if (error != nil) {
                        
                        self.dismissSVProgress()
                        self.noInternetConnection()
                        self.addressTextField.isEnabled = false
                        
                    } else {
                        
                        let jsonDict = JSON as? NSDictionary
                        let getAddressesResponse = jsonDict!["error"]
                        let getAdressesMessage = jsonDict!["error_msg"]
                        
                        if (getAddressesResponse as? Int == 1 ) {
                            
                            self.dismissSVProgress()
                            self.displayAlertMessage(title: "", messageToDisplay: getAdressesMessage as! String)
                            
                        } else {
                            
                            self.dismissSVProgress()
                            let address = jsonDict!["addresses"]
                            self.addressList = Mapper<AdressModel>().mapArray(JSONObject: address)!
                            
                            if (self.addressList.count > 0) {
                                
                                self.selectedAdress = self.addressList[0]
                                self.addressTextField.text = self.addressList[0].addressName
                            }
                        }
                    }
                }
            }
        }
    }
