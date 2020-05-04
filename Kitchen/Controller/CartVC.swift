//
//  CartVC.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 3/13/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import DLRadioButton
import Alamofire
import SwiftyJSON
import ObjectMapper
import SVProgressHUD

class CartVC: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subTotalPriceLabel: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var promoCodeButton: DLRadioButton!
    @IBOutlet weak var pointsButton: DLRadioButton!
    @IBOutlet weak var promoCodeTF: UITextField!
    @IBOutlet weak var promoCodeView: UIView!
    @IBOutlet weak var promoCodeImage: UIImageView!
    @IBOutlet weak var notPromoCodeImage: UIImageView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var etaLabell: UILabel!
    
    var dishList = [[String:Any]]()
    var etaArray = [String]()
    var subTotal : Int = 0
    var discount : Double = 0
    var total : Double = 0

    var isChecked = false {
        didSet {
            
            if isChecked == true {
                
                isPointsChecked = false
                discountLabel.text = "0"
                promoCodeButton.isSelected = true
                pointsButton.isSelected = false
                promoCodeTF.isHidden = false
                promoCodeView.isHidden = false
                updateTotal()
                
            } else {
                    
                if (pointsButton.isSelected) {
                    
                    discountLabel.text = "0"
                    promoCodeFuncIsHidden()
                    updateTotal()
                    
                } else {
                    
                    discountLabel.text = "0"
                    promoCodeButton.isSelected = false
                    pointsButton.isSelected = false
                    promoCodeFuncIsHidden()
                    updateTotal()
                }
            }
        }
    }
    
    var isPointsChecked = false {
        didSet {

            if isPointsChecked == true {

                isChecked = false
                discountLabel.text = "0"
                pointsButton.isSelected = true
                promoCodeButton.isSelected = false
                promoCodeFuncIsHidden()
                updateTotal()

            } else {
                
                if (promoCodeButton.isSelected) {
                    
                    discountLabel.text = "0"
                    promoCodeFuncIsHidden()
                    updateTotal()
                    
                } else {
                    
                    pointsButton.isSelected = false
                    promoCodeFuncIsHidden()
                    updateTotal()
                }
            }
        }
    }
    
    func promoCodeFuncIsHidden() {
        
        promoCodeTF.isHidden = true
        promoCodeView.isHidden = true
        promoCodeImage.isHidden = true
        notPromoCodeImage.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CartVC.functionName), name:NSNotification.Name(rawValue: "NotificationID"), object: nil)

        promoCodeTF.isHidden = true
        promoCodeView.isHidden = true
        promoCodeImage.isHidden = true
        notPromoCodeImage.isHidden = true
        
        for mentItem in User.shared.cart {
            subTotal = subTotal + (Int(mentItem.price)! * mentItem.qty)
            etaArray.append(mentItem.eta)
        }
        subTotalPriceLabel.text = "\(subTotal)"
        totalPriceLabel.text = "\(subTotal)"
        discountLabel.text = "\(0)"
        var maxEtaValue = etaArray.max()
        etaLabell.text = maxEtaValue
    }

//  Reload the view after checking the network connectivity and it is working
    @objc func functionName() {
        checkPromoCode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
//        For Making status bar in black color
//        if #available(iOS 13.0, *) {
//            UIApplication.shared.statusBarStyle = .darkContent
//        } else {
//            UIApplication.shared.statusBarStyle = .default
//        }
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {

        performSegue(withIdentifier: "goBackToKitchen", sender: self)
    }
    
    @IBAction func removeIteamsButtonPressed(_ sender: UIButton) {
        
        if User.shared.cart.count < 1 {
            
            self.displayAlertMessage(title: "", messageToDisplay: "Cart already empty")
            
        } else {
            
            let alert = UIAlertController(title: "Warning", message: "Do you really want to empty your cart?" , preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Yes", style: .default) { (alert) in
                
                User.shared.cart.removeAll()
                User.shared.saveData()
                self.tableView.reloadData()
                self.updateTotal()
            }
            let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alert.addAction(cancel)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func proceedButtonPressed(_ sender: Any) {
        
        if (User.shared.isRegistered()) {
            
            if User.shared.cart.count == 0 {
                
                displayAlertMessage(title: "", messageToDisplay: "Cart is empty!")
                
            } else {
                
                self.performSegue(withIdentifier: "goToConfirmPopup", sender: self)
            }
            
        } else {
            
            if User.shared.cart.count == 0 {
                
                displayAlertMessage(title: "", messageToDisplay: "Cart is empty!")
                
            } else {
                
                self.performSegue(withIdentifier: "goToLoginPopup", sender: self)
            }
        }
    }
    
    @IBAction func promoCodeEditingChanged(_ sender: Any) {
        
        if self.promoCodeTF.text?.count == 6 {
            self.checkPromoCode()
            
        } else if self.promoCodeTF.text?.count == 0 {
            
            notPromoCodeImage.isHidden = true
            promoCodeImage.isHidden = true
            updateTotal()
            
        } else {
            
            promoCodeImage.isHidden = true
            notPromoCodeImage.isHidden = false
            updateTotal()
        }
    }
    
    @IBAction func promoCodeButtonPressed(_ sender: DLRadioButton) {
        isChecked = !isChecked
    }
    
    @IBAction func pointsButtonPressed(_ sender: DLRadioButton) {
        isPointsChecked = !isPointsChecked
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "goToConfirmPopup") {
            
            let vc = segue.destination as! InformationConfirmationVC
            for item in User.shared.cart {
                dishList.append(["id" : item.id,
                                 "quantity": item.qty])
            }
            vc.dishList = dishList
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if User.shared.cart.count == 0 {
//          displayAlertMessage(title: "", messageToDisplay: "Cart is empty!")
        }
        return User.shared.cart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CartCell
        let menuItem = User.shared.cart[indexPath.row]
        
        if (menuItem.size == 0 && menuItem.selectedOption1 == "" && menuItem.selectedOption2 == "") {
            
            cell.sizeLabel.text = "Large"
            
        } else if (menuItem.size != 0 && menuItem.selectedOption1 == "" && menuItem.selectedOption2 == ""){
            
            cell.sizeLabel.text = "\(menuItem.selectedSize)"
            cell.priceLabel.text = "\(Int(menuItem.price)! * menuItem.qty)"
            
        } else if (menuItem.size == 0 && menuItem.selectedOption1 != "" && menuItem.selectedOption2 != "") {
            
            cell.sizeLabel.text = "Large" + ", \(menuItem.selectedOption1)" + ",and \(menuItem.selectedOption2)"
            
        } else if (menuItem.size == 0 && menuItem.selectedOption1 != "") {
            
            cell.sizeLabel.text = "Large" + ", \(menuItem.selectedOption1)"
        }

        cell.nameLabel.text = menuItem.name
        cell.priceLabel.text = "\(Int(menuItem.price)! * menuItem.qty)"
        cell.quantityLabel.text = "\(menuItem.qty)"
        cell.incremetButton.addTarget(self, action: #selector(incrmentButtonclicked(_:)), for: .touchUpInside)
        cell.decrementButton.addTarget(self, action: #selector(decrementButtonclicked(_:)), for: .touchUpInside)
        cell.incremetButton.tag = 100 + indexPath.row
        cell.decrementButton.tag = 100 + indexPath.row
        cell.selectionStyle = .none
        return cell
    }
    
    
    @objc func incrmentButtonclicked(_ sender : UIButton) {
        
        if (sender.tag >= 100) {
            
            User.shared.cart[sender.tag - 100].qty = User.shared.cart[sender.tag - 100].qty + 1
            User.shared.saveData()
            
            let cell = tableView.cellForRow(at: IndexPath(row: sender.tag - 100, section: 0)) as! CartCell
            cell.quantityLabel.text = "\(User.shared.cart[sender.tag - 100].qty)"
            cell.priceLabel.text = "\(Int(User.shared.cart[sender.tag - 100].qty) * Int(User.shared.cart[sender.tag - 100].price)!)"
            updateTotal()
        }
    }
    
    @objc func decrementButtonclicked(_ sender : UIButton) {
        
        if (sender.tag >= 100) {
            
            if User.shared.cart[sender.tag - 100].qty > 1 {
                
                User.shared.cart[sender.tag - 100].qty = User.shared.cart[sender.tag - 100].qty - 1
                User.shared.saveData()
                
                let cell = tableView.cellForRow(at: IndexPath(row: sender.tag - 100, section: 0)) as! CartCell
                cell.quantityLabel.text = "\(User.shared.cart[sender.tag - 100].qty)"
                cell.priceLabel.text = "\(Int(User.shared.cart[sender.tag - 100].qty) * Int(User.shared.cart[sender.tag - 100].price)!)"
                updateTotal()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            User.shared.cart.remove(at: indexPath.row)
            tableView.reloadData()
            User.shared.saveData()
            updateTotal()
        }
    }
    
    func updateTotal() {
        
        subTotal = 0
        etaArray = ["0"]
        
        for mentItem in User.shared.cart {
            subTotal = subTotal + (Int(mentItem.price)! * mentItem.qty)
            etaArray.append(mentItem.eta)
        }
        
        if (promoCodeButton.isSelected) {
            
            if (User.shared.isRegistered()) {
                checkPromoCode()
            } else {
                displayAlertMessage(title: "", messageToDisplay: "You must login first.")
                isChecked = false
            }
            
        } else if (pointsButton.isSelected) {
            
            if (User.shared.isRegistered()) {
                pointsCalculation()
            } else {
                displayAlertMessage(title: "", messageToDisplay: "You must login first.")
                isPointsChecked = false
            }
            
        } else {
            
            subTotalPriceLabel.text = "\(subTotal)"
            totalPriceLabel.text = "\(subTotal)"
            var maxEtaValue = etaArray.max()
            etaLabell.text = maxEtaValue
        }
    }
    
    func pointsCalculation() {
        print("Calculate Points")
    }
}

extension CartVC {
    
    func checkPromoCode() {
        
        DispatchQueue.main.async {
            
            let params  = ["user_id" : User.shared.id! ,"promocode" : self.promoCodeTF.text! ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .promoCode, parameters: params) { (JSON, error) -> Void in
                
                if(error != nil) {
                    
                    self.noInternetConnection()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let promoCodeResponse = jsonDict!["error"]
                    let promoCodeDisocunt = jsonDict!["discount"]
                    
                    if (promoCodeResponse as? Int == 1) {
                        
                        if self.promoCodeTF.text?.count == 0 {
                            
                            self.notPromoCodeImage.isHidden = true
                            self.promoCodeImage.isHidden = true
                            self.subTotalPriceLabel.text = "\(self.subTotal)"
                            self.totalPriceLabel.text = "\(self.subTotal)"
                            self.discountLabel.text = "\(0)"
                            
                        } else {
                            
                        self.notPromoCodeImage.isHidden = false
                        self.promoCodeImage.isHidden = true
                        self.subTotalPriceLabel.text = "\(self.subTotal)"
                        self.totalPriceLabel.text = "\(self.subTotal)"
                        self.discountLabel.text = "\(0)"
                        }
                        
                    } else {
                        
                        self.promoCodeImage.isHidden = false
                        self.notPromoCodeImage.isHidden = true
                        self.discount = promoCodeDisocunt as! Double
                        self.discountLabel.text = String ("\(self.discount)%")
                        self.subTotalPriceLabel.text = "\(self.subTotal)"
                        self.total = Double (self.subTotal) * self.discount/100
                        self.totalPriceLabel.text = String(Double(self.subTotal) - self.total)
                    }
                }
            }
        }
    }
}
