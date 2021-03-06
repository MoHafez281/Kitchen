//
//  Addresses.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 4/6/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import ObjectMapper

class AddressesVC: UIViewController {

    var addressesList = [AdressModel]()
    static var dismissBackButton : Int = 1 //If user go to AddressesVC from InformationConfirmatioVC, AddressesVC will appear as presenation style so this var to let back button act as dismiss else act normally
    
    @IBOutlet weak var tv: UITableView!
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reload the view after checking the network connectivity and it is working
        NotificationCenter.default.addObserver(self, selector: #selector(AddressesVC.functionName), name:NSNotification.Name(rawValue: "NotificationsID"), object: nil)

        tv.reloadData()
    }
    
     //Reload the view after checking the network connectivity and it is working
    @objc func functionName() {
        getAddresses()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAddresses()
    }
    
    @IBAction func backButtonClicked(_ sender: UIBarButtonItem) {
        
        if(self.navigationController!.viewControllers.count > 1) {
            self.navigationController?.popViewController(animated: true)
        } else if (AddressesVC.dismissBackButton == 2) {
            dismiss(animated: true)
//          If user go to AddressesVC from InformationConfirmatioVC, AddressesVC will appear as presenation style so this var to let back button act as dismiss else act normally
        } else {
            performSegue(withIdentifier: "backToSettings", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "EditAddress") {
            let vc = segue.destination as! AddNewAddress
            if let selectedAddress = sender as? AdressModel {
                vc.selectedAddress = selectedAddress
            }
        }
    }
}

extension AddressesVC :UITableViewDelegate , UITableViewDataSource {
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
    
            tv.reloadData()
        }
    }
}

extension AddressesVC {
    
    func getAddresses(){
        
        DispatchQueue.main.async {
            
            let params  = ["user_id" : User.shared.id ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .getAddress, parameters: params) { (JSON, error) -> Void in
                
                if(error != nil) {
                    
                    // show error
                    self.dismissSVProgress()
                    self.noInternetConnection()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    
                    let menusResponse = jsonDict!["error"] as! Bool
                    if(menusResponse){
                        
                        self.displayAlertMessage(title: "", messageToDisplay: "\(menusResponse)")

                    } else {
                        
                        let address = jsonDict!["addresses"]
                        self.addressesList = Mapper<AdressModel>().mapArray(JSONObject: address)!
                        self.tv.reloadData()
                    }
                }
            }
        }
    }
    
    func removeAddress(addressId : Int) {
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
                    let jsonError = jsonDict!["error"] as! Bool
                    if(jsonError){
                        
                        self.displayAlertMessage(title: "", messageToDisplay: "\(jsonError)")
                        
                    } else {
                        
                        
                    }
                }
            }
        }
    }
}

