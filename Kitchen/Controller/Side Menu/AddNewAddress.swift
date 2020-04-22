//
//  AddNewAddress.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 4/21/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import ObjectMapper
import CoreLocation

class AddNewAddress: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var textfields: UITextField!
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var addressNameTextField: UITextField!
    @IBOutlet weak var streerTextField: UITextField!
    @IBOutlet weak var buildingNoTextField: UITextField!
    @IBOutlet weak var floorNoTextField: UITextField!
    @IBOutlet weak var apartmentNoTextField: UITextField!
    @IBOutlet weak var landmarkTextField: UITextField!
    @IBOutlet weak var fullAddressTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addAddressLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var lat : String = ""
    var lon : String = ""
    var selectedAddress : AdressModel?
    var selectedLocation : String?
    let location = ["", "October", "Dokki", "Giza" , "Nasr City" , "Smart Village" , "Zamalek" , "Agouza" , "Maadi"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//      For dismissing loading view if coming back from view that ladoing data
        SVProgressHUD.dismiss()

        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        areaTextField.inputView = pickerView
        
        if(selectedAddress != nil){
            
            addAddressLabel.text = "Edit Address"
            areaTextField.text = selectedAddress!.area
            addressNameTextField.text = selectedAddress!.addressName
            fullAddressTextField.text = selectedAddress!.fullAddress
            streerTextField.text = selectedAddress!.street
            buildingNoTextField.text = selectedAddress!.buldingNumber
            floorNoTextField.text = selectedAddress!.floor
            apartmentNoTextField.text = selectedAddress!.aparmentNumber
            landmarkTextField.text = selectedAddress!.landmark
            
        }
        
        self.floorNoTextField.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            
            self.locationManager.stopUpdatingLocation()
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            lon = String(location.coordinate.latitude)
            lat = String(location.coordinate.longitude)
            
        }
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        let alert = UIAlertController(title: "Error", message: "Location Unavaliable, cannot get the cuurent location" , preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //Write the digits only method here:
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == floorNoTextField {
            let allowedCharacters = CharacterSet.decimalDigits //for digits only
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        return false
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
        selectedLocation = location[row]
        areaTextField.text = selectedLocation
    }
    
    @IBAction func changePlaceHolderColor(_ sender: UITextField) {
        if sender.tag == 0 {
            placeholder(textFields: areaTextField, placeHolderName: "Area", color: .lightGray)
        } else if sender.tag == 1 {
            placeholder(textFields: addressNameTextField, placeHolderName: "Address Name", color: .lightGray)
        } else if sender.tag == 2 {
            placeholder(textFields: fullAddressTextField, placeHolderName: "Full Address", color: .lightGray)
        } else if sender.tag == 3 {
            placeholder(textFields: streerTextField, placeHolderName: "Street", color: .lightGray)
        } else if sender.tag == 4 {
            placeholder(textFields: buildingNoTextField, placeHolderName: "Bulding No.", color: .lightGray)
        } else if sender.tag == 5 {
            placeholder(textFields: floorNoTextField, placeHolderName: "Floor No.", color: .lightGray)
        } else if sender.tag == 6 {
            placeholder(textFields: apartmentNoTextField, placeHolderName: "Apartment No.", color: .lightGray)
        } else if sender.tag == 7 {
            placeholder(textFields: landmarkTextField, placeHolderName: "Landmark", color: .lightGray)
        }
        
    }

    func checkTextFieldsEmpty() {
        
        dismissSVProgress()
        placeholder(textFields: areaTextField, placeHolderName: "Area", color: .red)
        placeholder(textFields: addressNameTextField, placeHolderName: "Address Name", color: .red)
        placeholder(textFields: fullAddressTextField, placeHolderName: "Full Address", color: .red)
        placeholder(textFields: streerTextField, placeHolderName: "Steet", color: .red)
        placeholder(textFields: buildingNoTextField, placeHolderName: "Bulding No.", color: .red)
        placeholder(textFields: floorNoTextField, placeHolderName: "Floor No.", color: .red)
        placeholder(textFields: apartmentNoTextField, placeHolderName: "Apartment No.", color: .red)
        placeholder(textFields: landmarkTextField, placeHolderName: "Landmark", color: .red)
        
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
        
        if(selectedAddress == nil) {
            
            if areaTextField.text == "" || addressNameTextField.text == "" || fullAddressTextField.text == "" || streerTextField.text == "" || buildingNoTextField.text == "" || floorNoTextField.text == "" || apartmentNoTextField.text == "" || landmarkTextField.text == "" {
                checkTextFieldsEmpty()
            } else {
                addAddress(userId: User.shared.id! , lon: lon , lat: lat)
            }
            
        } else {
            
            if areaTextField.text == "" || addressNameTextField.text == "" || fullAddressTextField.text == "" || streerTextField.text == "" || buildingNoTextField.text == "" || floorNoTextField.text == "" || apartmentNoTextField.text == "" || landmarkTextField.text == "" {
                checkTextFieldsEmpty()
            } else {
                editAddress()
            }
        }
    }
}

extension AddNewAddress {
    
    func addAddress(userId: Int , lon: String , lat: String) {
        
        DispatchQueue.main.async {
            
            let params  = ["user_id" : userId , "floor" : self.floorNoTextField.text! , "apartmentNumber" : self.apartmentNoTextField.text! , "buildingNumber" : self.buildingNoTextField.text! , "area" : self.areaTextField.text! , "addressName" : self.addressNameTextField.text! , "street" : self.streerTextField.text! , "landMark" : self.landmarkTextField.text! , "latitude" : lat, "longitude" : lon, "fullAddress" : self.fullAddressTextField.text!] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .addAddress , parameters: params) { (JSON, error) -> Void in
                
                if(error != nil){
                    
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
                        let alert = UIAlertController(title: "New Address", message: registerMessage as! String, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }
            }
        }
    }
    
    func editAddress() {
        
        DispatchQueue.main.async {
            
            var customeurl = hostName + "edit_address/\(self.selectedAddress!.id)/\(User.shared.id!)/\(self.floorNoTextField.text!)/\(self.apartmentNoTextField.text!)/\(self.buildingNoTextField.text!)/\(self.areaTextField.text!)/\(self.addressNameTextField.text!)/\(self.fullAddressTextField.text!)/\(self.streerTextField.text!)/\(self.landmarkTextField.text!)/\(12.3456)/\(12.3456)"
            customeurl = customeurl.replacingOccurrences(of: " ", with: "%20")
            
            let manager = Manager()
            manager.perform(methodType: .put, useCustomeURL : true, urlStr: customeurl, serviceName: .addAddress ,  parameters: nil) { (JSON, error) -> Void in
                
                if(error != nil){
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let registerResponse = jsonDict!["error"]
                    let registerMessage = jsonDict?["message"]
                    
                    if (registerResponse as? Int == 1) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: registerMessage as! String)
                    }
                    
                    self.dismissSVProgress()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
