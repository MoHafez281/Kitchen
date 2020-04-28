//
//  AddNewAddressVC.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 4/21/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import ObjectMapper
import CoreLocation

class AddNewAddressVC: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var textfields: UITextField!
    @IBOutlet weak var areaPickerTF: UITextField!
    @IBOutlet weak var addressNameTF: UITextField!
    @IBOutlet weak var streerTF: UITextField!
    @IBOutlet weak var buildingNoTF: UITextField!
    @IBOutlet weak var floorNoTF: UITextField!
    @IBOutlet weak var apartmentNoTF: UITextField!
    @IBOutlet weak var landmarkTF: UITextField!
    @IBOutlet weak var fullAddressTF: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addAddressLabel: UILabel!
        
    var lat : String = ""
    var lon : String = ""
    var selectedAddress : AdressModel?
    var selectedLocation : String?
    let location = ["October", "Dokki", "Giza" , "Nasr City" , "Smart Village" , "Zamalek" , "Agouza" , "Maadi"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        areaPickerTF.inputView = pickerView
        
        if (selectedAddress != nil) {
            
            addAddressLabel.text = "Edit Address"
            areaPickerTF.text = selectedAddress!.area
            addressNameTF.text = selectedAddress!.addressName
            fullAddressTF.text = selectedAddress!.fullAddress
            streerTF.text = selectedAddress!.street
            buildingNoTF.text = selectedAddress!.buldingNumber
            floorNoTF.text = selectedAddress!.floor
            apartmentNoTF.text = selectedAddress!.aparmentNumber
            landmarkTF.text = selectedAddress!.landmark
        }
        
        self.floorNoTF.delegate = self
    }
    
    //Write the digits only method here:
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == floorNoTF {
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
        areaPickerTF.text = selectedLocation
    }
    
    @IBAction func changePlaceHolderColor(_ sender: UITextField) {
        if sender.tag == 0 {
            placeholder(textFields: areaPickerTF, placeHolderName: "Area", color: .lightGray)
        } else if sender.tag == 1 {
            placeholder(textFields: addressNameTF, placeHolderName: "Address Name", color: .lightGray)
        } else if sender.tag == 2 {
            placeholder(textFields: fullAddressTF, placeHolderName: "Full Address", color: .lightGray)
        } else if sender.tag == 3 {
            placeholder(textFields: streerTF, placeHolderName: "Street", color: .lightGray)
        } else if sender.tag == 4 {
            placeholder(textFields: buildingNoTF, placeHolderName: "Bulding No.", color: .lightGray)
        } else if sender.tag == 5 {
            placeholder(textFields: floorNoTF, placeHolderName: "Floor No.", color: .lightGray)
        } else if sender.tag == 6 {
            placeholder(textFields: apartmentNoTF, placeHolderName: "Apartment No.", color: .lightGray)
        } else if sender.tag == 7 {
            placeholder(textFields: landmarkTF, placeHolderName: "Landmark", color: .lightGray)
        }
    }

    func checkTextFieldsEmpty() {
        
        placeholder(textFields: areaPickerTF, placeHolderName: "Area", color: .red)
        placeholder(textFields: addressNameTF, placeHolderName: "Address Name", color: .red)
        placeholder(textFields: fullAddressTF, placeHolderName: "Full Address", color: .red)
        placeholder(textFields: streerTF, placeHolderName: "Street", color: .red)
        placeholder(textFields: buildingNoTF, placeHolderName: "Bulding No.", color: .red)
        placeholder(textFields: floorNoTF, placeHolderName: "Floor No.", color: .red)
        placeholder(textFields: apartmentNoTF, placeHolderName: "Apartment No.", color: .red)
        placeholder(textFields: landmarkTF, placeHolderName: "Landmark", color: .red)
        
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        if (selectedAddress == nil) {
            
            if areaPickerTF.text == "" || addressNameTF.text == "" || fullAddressTF.text == "" || streerTF.text == "" || buildingNoTF.text == "" || floorNoTF.text == "" || apartmentNoTF.text == "" || landmarkTF.text == "" {
                checkTextFieldsEmpty()
                
            } else {
                
                if areaPickerTF.text == "Maadi" {
                    addAddress(userId: User.shared.id! , lon: "123.123" , lat: "123.123")
                    
                } else {
                    
                let alert = UIAlertController(title: "Warning", message: "Available in Maadi only, Are you sure you want to register with this selected location?" , preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Yes", style: .default) { (alert) in
                    
                    self.addAddress(userId: User.shared.id! , lon: "123.123" , lat: "123.123")
                }
                    
                let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
                alert.addAction(cancel)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                }
            }
            
        } else {
            
            if areaPickerTF.text == "" || addressNameTF.text == "" || fullAddressTF.text == "" || streerTF.text == "" || buildingNoTF.text == "" || floorNoTF.text == "" || apartmentNoTF.text == "" || landmarkTF.text == "" {
                
                checkTextFieldsEmpty()
                
            } else {
                
                if areaPickerTF.text == "Maadi" {
                        editAddress()
                    
                } else {
                    
                let alert = UIAlertController(title: "Warning", message: "Available in Maadi only, Are you sure you want to register with this selected location?" , preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Yes", style: .default) { (alert) in
                    
                    self.editAddress()
                }
                    
                let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
                alert.addAction(cancel)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension AddNewAddressVC {
    
    func addAddress(userId: Int , lon: String , lat: String) {
        
        showSVProgress()
        DispatchQueue.main.async {
            
            let params  = ["user_id" : userId , "floor" : self.floorNoTF.text! , "apartmentNumber" : self.apartmentNoTF.text! , "buildingNumber" : self.buildingNoTF.text! , "area" : self.areaPickerTF.text! , "addressName" : self.addressNameTF.text! , "street" : self.streerTF.text! , "landMark" : self.landmarkTF.text! , "latitude" : lat, "longitude" : lon, "fullAddress" : self.fullAddressTF.text!] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .addAddress , parameters: params) { (JSON, error) -> Void in
                
                if(error != nil){
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let addAddressResponse = jsonDict!["error"]
                    let addAddressMessage = jsonDict?["message"]
                    
                    if (addAddressResponse as? Int == 1) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: addAddressMessage as! String)
                        
                    } else {
                        
                        self.dismissSVProgress()
                        let user: User = Mapper<User>().map(JSONObject: JSON)!
                        let alert = UIAlertController(title: "", message: "The address has been added successfully.", preferredStyle: .alert)
//                      Reload addressPickerView after a new address added or edited
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddressAdded/Edited"), object: nil)
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
        
        showSVProgress()
        DispatchQueue.main.async {
            
            var customeurl = hostName + "edit_address/\(self.selectedAddress!.id)/\(User.shared.id!)/\(self.floorNoTF.text!)/\(self.apartmentNoTF.text!)/\(self.buildingNoTF.text!)/\(self.areaPickerTF.text!)/\(self.addressNameTF.text!)/\(self.fullAddressTF.text!)/\(self.streerTF.text!)/\(self.landmarkTF.text!)/\(12.3456)/\(12.3456)"
            customeurl = customeurl.replacingOccurrences(of: " ", with: "%20")
            
            let manager = Manager()
            manager.perform(methodType: .put, useCustomeURL : true, urlStr: customeurl, serviceName: .addAddress ,  parameters: nil) { (JSON, error) -> Void in
                
                if (error != nil) {
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let editAddressResponse = jsonDict!["error"]
                    let editAddressMessage = jsonDict?["message"]
                    
                    if (editAddressResponse as? Int == 1) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: editAddressMessage as! String)
                        
                    } else {
                        
                        self.dismissSVProgress()
                        let alert = UIAlertController(title: "", message: "The address has been updated successfully.", preferredStyle: .alert)
//                      Reload addressPickerView at ProfileVC & InformationConfirmationVC after a new address added or edited
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddressAdded/Edited"), object: nil)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
