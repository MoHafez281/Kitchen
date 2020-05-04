    //
    //  ProfileVC.swift
    //  Kershoman
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
    
    class ProfileVC: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource, UITextFieldDelegate {
        
        @IBOutlet weak var fullNameTF: UITextField!
        @IBOutlet weak var emailTF: UITextField!
        @IBOutlet weak var addressTF: UITextField!
        @IBOutlet weak var mobileNumberTF: UITextField!
        @IBOutlet weak var birthdayDateTF: UITextField!
        @IBOutlet weak var jobTF: UITextField!
        @IBOutlet weak var locationPickerTF: UITextField!
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
            NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.functionName), name:NSNotification.Name(rawValue: "NotificationID"), object: nil)
//          Reload addressPickerView at ProfileVC & InformationConfirmationVC after a new address added or edited
            NotificationCenter.default.addObserver(self, selector: #selector(LoginPopupVC.functionName), name:NSNotification.Name(rawValue: "AddressAdded/Edited"), object: nil)
            
            AddressesVC.dismissBackButtonAddressesVC = 1 //If user go to AddressesVC from InformationConfirmatioVC, AddressesVC will appear as presenation style so this var to let back button act as dismiss else act normally
            
            emailTF.isEnabled = false //This field cannot be changed
            mobileNumberTF.isEnabled = false //This field cannot be changed
            
//          DatePicker View
//          For setting the maximum year 2015 & minimum 1900
//            var maximumYear: Date {
//                return (Calendar.current as NSCalendar).date(byAdding: [.day,.month,.year], value: 31/12/2015, to: Date(), options: [])!
//            }
//            var minimumYear: Date {
//                return (Calendar.current as NSCalendar).date(byAdding: [.day,.month,.year], value: 01/01/1900, to: Date(), options: [])!
//            }
            let calendar = Calendar.current
            var minDateComponent = calendar.dateComponents([.day,.month,.year], from: Date())
            minDateComponent.day = 01
            minDateComponent.month = 01
            minDateComponent.year = 1900

            let minDate = calendar.date(from: minDateComponent)
            print(" min date : \(String(describing: minDate))")

            var maxDateComponent = calendar.dateComponents([.day,.month,.year], from: Date())
            maxDateComponent.day = 31
            maxDateComponent.month = 12
            maxDateComponent.year = 2015

            let maxDate = calendar.date(from: maxDateComponent)
            print("max date : \(String(describing: maxDate))")


//           DatePicker View
            datePicker = UIDatePicker()
            datePicker?.minimumDate = minDate! as Date
            datePicker?.maximumDate =  maxDate! as Date
//          datePicker?.maximumDate = maximumYear
//          datePicker?.minimumDate = minimumYear
            datePicker?.datePickerMode = .date
            datePicker?.addTarget(self, action: #selector(ProfileVC.dateChanged(datePicker:)), for: .valueChanged)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.viewTapped(gestureRecognizer:)))
            view.addGestureRecognizer(tapGesture)
            birthdayDateTF.inputView = datePicker
            
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
            birthdayDateTF.text = dateFormatter.string(from: datePicker.date)
        }
        
//      Reload the view after checking the network connectivity and it is working
//      Reload addressPickerView at ProfileVC & InformationConfirmationVC after a new address added or edited
        @objc func functionName() {
            getProfile()
            getAddresses()
        }
        
        @IBAction func sideBarButtonPressed(_ sender: Any) {
            self.sideMenuController?.revealMenu()
        }
            
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            
            if currentTextField == locationPickerTF {
                return location.count
            } else if currentTextField == addressTF {
                return addressList.count
            } else {
                return 0
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            
            if currentTextField == locationPickerTF {
                return location[row]
            } else if currentTextField == addressTF  {
               return addressList[row].addressName
            } else {
              return ""
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            
            if currentTextField == locationPickerTF {
                
                locationPickerTF.text = location[row]
                self.view.endEditing(true)
                
            } else if currentTextField == addressTF {
                
                addressTF.text = addressList[row].addressName
                selectedAdress = addressList[row]
                self.view.endEditing(true)
            }
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            self.pickerView.delegate = self
            self.pickerView.dataSource = self
            currentTextField = textField
            
            if currentTextField == locationPickerTF {
                currentTextField.inputView = pickerView
            } else if currentTextField == addressTF {
                currentTextField.inputView = pickerView
            }
        }
        
        
        @IBAction func saveButtonPressed(_ sender: UIButton) {
            
            if locationPickerTF.text == "Maadi" {
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
        
        func getProfile() {
        
            saveButton.isEnabled = false //Disable it till all data are showed to the user
            showSVProgress()
            DispatchQueue.main.async {
                
                let params  = ["user_id" : User.shared.id ] as [String: AnyObject]
                let manager = Manager()
                manager.perform(serviceName: .getProfile, parameters: params) { (JSON, error) -> Void in
                    
                    if (error != nil) {
                        
                        self.dismissSVProgress()
                        self.noInternetConnection()
                        self.addressTF.isEnabled = false //As if there is connection error user will not able to open this TF as its get data from back end so if open it app will crash
                        
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
                            
                            self.dismissSVProgress()
                            let user: User = Mapper<User>().map(JSONObject: JSON)!
                            User.shared.setIsRegister(registered: true)
                            User.shared.fillUserModel(model: user)
                            User.shared.saveData()
                            self.fullNameTF.text = User.shared.name
                            self.emailTF.text = User.shared.email
                            self.mobileNumberTF.text = User.shared.phone
                            self.birthdayDateTF.text = User.shared.birthday
                            self.jobTF.text = User.shared.job
                            self.addressTF.text = User.shared.address
                            self.locationPickerTF.text = User.shared.location
                            self.saveButton.isEnabled = true
                        }
                    }
                }
            }
        }
        
        func updateProfile() {

            showSVProgress()
            DispatchQueue.main.async {
                
                let params  = ["id" : User.shared.id! , "name" : self.fullNameTF.text! , "add_id" : self.selectedAdress?.id as Any , "date_of_birth" : self.birthdayDateTF.text! , "location" : self.locationPickerTF.text! , "job" : self.jobTF.text!] as [String: AnyObject]
                
                let manager = Manager()
                manager.perform(serviceName: .updateUser , parameters: params) { (JSON, error) -> Void in
                    
                    if (error != nil) {
                        
                        self.dismissSVProgress()
                        self.noInternetConnection()
                        self.addressTF.isEnabled = false //As if there is connection error user will not able to open this TF as its get data from back end so if open it app wil crash
                        
                    } else {
                        
                        let jsonDict = JSON as? NSDictionary
                        let updateProfileResponse = jsonDict!["error"]
                        let updateProfileMessage = jsonDict?["message"]
                        
                        if (updateProfileResponse as? Int == 1) {
                            
                            self.dismissSVProgress()
                            self.displayAlertMessage(title: "Error", messageToDisplay: updateProfileMessage as! String)
                            
                        } else {
                            
                            self.dismissSVProgress()
                            let alert = UIAlertController(title: "", message: "Your profile has been updated successfully." , preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                                
                                SideBar.checkVisiableView = 1 //To Check which SideMenuVC is visiable now, so to make HomeVC visiable now as segue to HomeVC
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
                        self.addressTF.isEnabled = false //As if there is connection error user will not able to open this TF as its get data from back end so if open it app wil crash
                        
                    } else {
                        
                        let jsonDict = JSON as? NSDictionary
                        let getAddressesResponse = jsonDict!["error"]
                        let getAdressesMessage = jsonDict!["error_msg"]
                        
                        if (getAddressesResponse as? Int == 1 ) {
                            
                            self.dismissSVProgress()
                            AddressesVC.addressAlartMessageAlreadyShowed = 2 //If no address message appear not appear it again while user add an address
                            self.displayAlertMessage(title: "", messageToDisplay: getAdressesMessage as! String)
                            self.addressTF.isEnabled = false //As if there is connection error user will not able to open this TF as its get data from back end so if open it app wil crash
                            self.placeholder(textFields: self.addressTF, placeHolderName: "No address added, please add one.", color: .red)
                            
                        } else {
                            
                            self.dismissSVProgress()
                            self.addressTF.isEnabled = true
                            let address = jsonDict!["addresses"]
                            self.addressList = Mapper<AdressModel>().mapArray(JSONObject: address)!
                            
                            if (self.addressList.count > 0) {
                                
                                self.selectedAdress = self.addressList[0]
                                self.addressTF.text = self.addressList[0].addressName
                            }
                        }
                    }
                }
            }
        }
    }
