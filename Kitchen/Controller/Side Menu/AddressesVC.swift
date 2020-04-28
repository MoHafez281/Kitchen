//
//  AddressesVC.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 4/6/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import ObjectMapper

class AddressesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var addressesList = [AdressModel]()
    static var dismissBackButtonAddressesVC : Int = 1 //If user go to AddressesVC from InformationConfirmatioVC, AddressesVC will appear as presenation style so this var to let back button act as dismiss else act normally
    static var addressAlartMessageAlreadyShowed : Int = 1 //If no address message appear not appear it again while user add an address
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//      Reload the view after checking the network connectivity and it is working
        NotificationCenter.default.addObserver(self, selector: #selector(AddressesVC.functionName), name:NSNotification.Name(rawValue: "NotificationsID"), object: nil)

        tableView.reloadData()
    }
    
//  Reload the view after checking the network connectivity and it is working
    @objc func functionName() {
        getAddresses()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAddresses()
    }
    
    @IBAction func backButtonClicked(_ sender: UIBarButtonItem) {
        
        if (self.navigationController!.viewControllers.count > 1) {
            self.navigationController?.popViewController(animated: true)
        } else if (AddressesVC.dismissBackButtonAddressesVC == 2) {
            dismiss(animated: true)
//          If user go to AddressesVC from InformationConfirmatioVC, AddressesVC will appear as presenation style so this var to let back button act as dismiss else act normally
        } else {
            performSegue(withIdentifier: "backToSettings", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "EditAddress") {
            let vc = segue.destination as! AddNewAddressVC
            if let selectedAddress = sender as? AdressModel {
                vc.selectedAddress = selectedAddress
            }
        }
    }
}

extension AddressesVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddressTVCell
        let address = addressesList[indexPath.row]
        
        cell.addressNameLabel.text = address.addressName
        cell.areaLabel.text = address.area
        cell.fullAddressLabel.text = address.fullAddress
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "EditAddress", sender: addressesList[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            removeAddress(addressId: addressesList[indexPath.row].id)
            addressesList.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

extension AddressesVC {
    
    func getAddresses() {
        
        showSVProgress()
        DispatchQueue.main.async {
            
            let params  = ["user_id" : User.shared.id ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .getAddress, parameters: params) { (JSON, error) -> Void in
                
                if(error != nil) {
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let getAddressesResponse = jsonDict!["error"] as! Bool
                    let getAdressesMessage = jsonDict!["error_msg"]
                    
                    if (getAddressesResponse) {
                        
                        self.dismissSVProgress()
                        if (AddressesVC.addressAlartMessageAlreadyShowed == 1) {
                            
                            self.displayAlertMessage(title: "Error", messageToDisplay: getAdressesMessage as! String)
                        } else {
                            //AlertMessage will not appear
                        }
                        
                    } else {
                        
                        self.dismissSVProgress()
                        AddressesVC.addressAlartMessageAlreadyShowed = 1 //If no address message appear not appear it again while user add an address
                        let address = jsonDict!["addresses"]
                        self.addressesList = Mapper<AdressModel>().mapArray(JSONObject: address)!
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func removeAddress(addressId : Int) {
        
        showSVProgress()
        DispatchQueue.main.async {
            
            var customeurl = hostName + "remove_address/\(addressId)"
            customeurl = customeurl.replacingOccurrences(of: " ", with: "%20")
            
            let manager = Manager()
            manager.perform(methodType: .delete, useCustomeURL : true, urlStr: customeurl, serviceName: .addAddress ,  parameters: nil) { (JSON, error) -> Void in
            
                if(error != nil) {
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let removeAddressError = jsonDict!["error"] as! Bool
                    if (removeAddressError) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "", messageToDisplay: "\(removeAddressError)")
                        
                    } else {
                        
                        self.dismissSVProgress()
                        //removed
                    }
                }
            }
        }
    }
}
