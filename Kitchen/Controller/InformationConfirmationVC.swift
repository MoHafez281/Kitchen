//
//  InformationConfirmationVC.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 3/30/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import ObjectMapper
import DLRadioButton

class InformationConfirmationVC: UIViewController , UITextFieldDelegate {
    
    @IBOutlet weak var addTempMobileOutlet: UISwitch!
    @IBAction func addTempMobile(_ sender: UISwitch) {
        
        if sender.isOn == true {
            mobileNumberTF.text = ""
            mobileNumberTF.isEnabled = true
            textSwitch = mobileNumberTF.text!
        } else {
            textSwitch = ""
            mobileNumberTF.isEnabled = false
            mobileNumberTF.text = User.shared.phone
            textSwitch = User.shared.phone!
        }
    }
    
    @IBOutlet weak var scheduleView: UIView!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var selectAddressTF: UITextField!
    @IBOutlet weak var mobileNumberTF: UITextField!
    @IBOutlet weak var nowRadioButton: DLRadioButton!
    @IBOutlet weak var laterRadioButton: DLRadioButton!
    
    var dishList = [[String:Any]]()
    var addressPickerView = UIPickerView()
    var addressList = [AdressModel]()
    var selectedAdress : AdressModel?
    var timePicker = UIDatePicker()
    var datePicker = UIDatePicker()
    var textSwitch : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//      Reload the view after checking the network connectivity and it is working
        NotificationCenter.default.addObserver(self, selector: #selector(InformationConfirmationVC.functionName), name:NSNotification.Name(rawValue: "NotificationID"), object: nil)
//      Reload addressPickerView at ProfileVC & InformationConfirmationVC after a new address added or edited
        NotificationCenter.default.addObserver(self, selector: #selector(LoginPopupVC.functionName), name:NSNotification.Name(rawValue: "AddressAdded/Edited"), object: nil)
        
        AddressesVC.dismissBackButtonAddressesVC = 2 //If user go to AddressesVC from InformationConfirmatioVC, AddressesVC will appear as presenation style so this var to let back button act as dismiss else act normally
        
        addTempMobileOutlet.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        addTempMobileOutlet.isOn = false
        mobileNumberTF.isEnabled = false
        mobileNumberTF.delegate = self
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        timePicker.datePickerMode = .time
        
//      11 to 20 is the kitchen working hours **
        if (hour >= 11 && hour <= 20) {
//          in case if he ordering while the kitchen is open, user has two options now or later
            nowRadioButton.isSelected = true
            scheduleView.isHidden = true
            datePicker.minimumDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "HH:mm"
            dateFormatter.locale = .current
            dateFormatter.timeZone = .current
//          below code is to handle later option pickers
//          time picker for later max order time is 20 **
            let max = dateFormatter.date(from: "20:00")
            
            if (hour <= 18) {
//              the user is selecting time while his local time is less than 6:00 PM
                timePicker.minimumDate = calendar.date(byAdding: .minute, value: 90, to: Date())
            } else {
//              the user is selecting time while his local time is bigger than 6:00 PM so he can't shedule order for today.
                let min = dateFormatter.date(from: "11:00")
                timePicker.minimumDate = min
                let date = calendar.date(byAdding: .day, value: 1, to: Date())
                datePicker.minimumDate = date
            }
            
            timePicker.maximumDate = max!
            
        } else {
            
//          in case if he ordering while the kitchen is closed so user has only one option "later"
            laterRadioButton.isSelected = true
            nowRadioButton.isEnabled = false
            scheduleView.isHidden = false
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "HH:mm"
            dateFormatter.locale = .current
            dateFormatter.timeZone = .current
//          this is the max and min time for the kitchen the min is kitchen opening hour + 90 for order prepration and delivery
            let min = dateFormatter.date(from: "12:30")
            let max = dateFormatter.date(from: "20:00")
            timePicker.minimumDate = min!
            timePicker.maximumDate = max!
            timePicker.date = min!
            
            if (hour >= 20) {
//              he is making order aftre the working hours
                let date = calendar.date(byAdding: .day, value: 1, to: Date())
                datePicker.minimumDate = date
                
            } else {
                
                datePicker.minimumDate = Date()
            }
        }
        
        getAddresses()
        dateTF.inputView = datePicker
        timeTF.inputView = timePicker
        mobileNumberTF.text! = User.shared.phone!
        selectAddressTF.inputView = addressPickerView
        addressPickerView.delegate = self
        datePicker.datePickerMode = .date
    }
    
//  Reload the view after checking the network connectivity and it is working
//  Reload addressPickerView after a new address added or edited
    @objc func functionName() {
        getAddresses()
    }
    
    @IBAction func NowButtonCliked(_ sender: DLRadioButton) {
        
        if(nowRadioButton.isSelected) {
            scheduleView.isHidden = true
        } else if (laterRadioButton.isSelected) {
            scheduleView.isHidden = false
        }
    }
    
    @IBAction func dismissPopup(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func didEndEditing(_ sender: UITextField) {
        dateTF.text = formatDate(date: datePicker.date)
    }
    
    @IBAction func timeDidEndEditing(_ sender: UITextField) {
        timeTF.text = formatTime(date: timePicker.date)
    }
    
    @IBAction func confirmAddressPressed(_ sender: UIButton) {
//      check for all the required parameters
        
        if selectedAdress?.area == "Maadi" {
            
            if mobileNumberTF.text == "" {
            
                displayAlertMessage(title: "", messageToDisplay: "Please, enter a temp mobile number.")
                placeholder(textFields: mobileNumberTF, placeHolderName: "Mobile Number", color: .red)
                
            } else if (mobileNumberTF.text?.count)! > 11 || (mobileNumberTF.text?.count)! < 11 {
                
                displayAlertMessage(title: "", messageToDisplay: "Please, enter a correct mobile number.")
                
            } else if (laterRadioButton.isSelected) {
                
                if dateTF.text == "" || timeTF.text == "" {
                    
                    displayAlertMessage(title: "", messageToDisplay: "Please, Fill the date & the time.")
                    placeholder(textFields: dateTF, placeHolderName: "Select the date.", color: .red)
                    placeholder(textFields: timeTF, placeHolderName: "Select the time.", color: .red)
                    
                } else {
                    performSegue(withIdentifier: "goToSummary", sender: self)
                }
                
            } else if (nowRadioButton.isSelected) {
                performSegue(withIdentifier: "goToSummary", sender: self)
            }
            
        } else {
            
            displayAlertMessage(title: "", messageToDisplay: "Please select or add address within the area, Available in Maadi Only.")
//            placeholder(textFields: self.selectAddressTF, placeHolderName: "Select or add address within the area.", color: .red)
            selectAddressTF.text = ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "goToSummary") {
            
            textSwitch = mobileNumberTF.text!
            let vc = segue.destination as! SummaryVC
            vc.addressId = selectedAdress!.id
            vc.detailedaddressConfirmAddress = (selectedAdress?.fullAddress)! + ", " + (selectedAdress?.street)! + ", " + (selectedAdress?.landmark)! + ", " + (selectedAdress?.area)! + ", " + (selectedAdress?.buldingNumber)! + ", " + (selectedAdress?.floor)! + ", " + (selectedAdress?.aparmentNumber)!
            
            if (nowRadioButton.isSelected) {
                
                vc.craetionTime = formatDateToSend(date: Date()) + " " + formatTime(date: Date())
                vc.orderTime = formatDateToSend(date: Date()) + " " + formatTime(date: Calendar.current.date(byAdding: .minute, value: 90, to: Date())!)
                
            } else {
                
                vc.orderTime = formatDateToSend(date: datePicker.date) + " " + timeTF.text!
                vc.craetionTime = formatDateToSend(date: Date()) + " " + formatTime(date: Date())
            }
            
            vc.dishList = dishList
            vc.schedule = laterRadioButton.isSelected
            vc.phoneNumber = textSwitch
            vc.location = (selectedAdress?.area)!
        }
    }
}

extension InformationConfirmationVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return addressList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return addressList[row].addressName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectAddressTF.text = addressList[row].addressName
        selectedAdress = addressList[row]
    }    
}

extension InformationConfirmationVC {
    
    func getAddresses() {
        
        DispatchQueue.main.async {
            
            let params  = ["user_id" : User.shared.id ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .getAddress, parameters: params) { (JSON, error) -> Void in
                
                if (error != nil) {
                    
                    self.noInternetConnection()
                    self.selectAddressTF.isEnabled = false //If no connection or no address added must be disabled else app will crash
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let getAddressResponse = jsonDict!["error"]
                    let getAddressMessage = jsonDict!["error_msg"]
                    
                    if (getAddressResponse as? Int == 1) {
                        
                        AddressesVC.addressAlartMessageAlreadyShowed = 2 //If no address message appear not appear it again while user add an address
                        self.selectAddressTF.isEnabled = false //If no connection or no address added must be disabled else app will crash
                        self.displayAlertMessage(title: "Error", messageToDisplay: getAddressMessage as! String)
                        self.placeholder(textFields: self.selectAddressTF, placeHolderName: "No address added, please add one.", color: .red)
                        
                    } else {
                        
                        self.placeholder(textFields: self.selectAddressTF, placeHolderName: "Address", color: .lightGray)
                        let address = jsonDict!["addresses"]
                        self.selectAddressTF.isEnabled = true
                        self.addressList = Mapper<AdressModel>().mapArray(JSONObject: address)!
                        
                        if (self.addressList.count > 0) {
                            
                            self.selectedAdress = self.addressList[0]
                            self.selectAddressTF.text = self.addressList[0].addressName
                        }
                    }
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == mobileNumberTF  {
            let allowedCharacters = CharacterSet.decimalDigits //for digits only
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        return false
    }
        
    func formatTime(date: Date) -> String {
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "HH:mm"
        
        let myString = formatter.string(from: date) // string purpose I add here
        // convert your string to date
        return myString
    }
    
    func formatDate(date: Date) -> String {
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "dd-MM-yyyy"
        
        let myString = formatter.string(from: date) // string purpose I add here
        // convert your string to date
        return myString
    }
    
    func formatDateToSend(date: Date) -> String {
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy/MM/dd"
        
        let myString = formatter.string(from: date) // string purpose I add here
        // convert your string to date
        return myString
    }
}
