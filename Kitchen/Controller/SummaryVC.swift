//
//  SummaryVC.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 4/6/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import SVProgressHUD

class SummaryVC: UIViewController , UITableViewDataSource , UITableViewDelegate {
    
    
    
    @IBOutlet weak var circleFilledSumbmitted: UIImageView!
    @IBOutlet weak var circleFilledRecieved: UIImageView!
    @IBOutlet weak var circleFilledReady: UIImageView!
    @IBOutlet weak var circleFilledDelivered: UIImageView!
    @IBOutlet weak var tableViewTopCnst: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var statusViewTopConst: NSLayoutConstraint!
    @IBOutlet weak var statusViewHeight: NSLayoutConstraint!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var deliveryTimeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mobileNumberLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    @IBOutlet weak var pointsDiscountLabel: UILabel!
    @IBOutlet weak var taxAmountLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var ProceedStackView: UIStackView!
    @IBOutlet weak var proceedLabel: UILabel!
    @IBOutlet weak var receiptView: UIView!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var isMyOrders = false
    var total : Double = 0
    var orderTime : String = ""
    var craetionTime : String = ""
    var addressId : Int = -1
    var detailedaddress : String = ""
    var detailedaddressConfirmAddress : String = ""
    var phoneNumber = ""
    var subtotal = 0
    var deliveryFees = 15
    var discount : Double = 0
    var dishList = [[String:Any]]()
    var schedule : Bool = false
    var location : String = ""
    var myOrder : Orders?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layer.borderWidth = 0.5
        receiptView.layer.borderWidth = 0.5
        totalView.layer.borderWidth = 0.5
        
        if (isMyOrders) {
            
            confirmButton.isHidden = true
            ProceedStackView.isHidden = true
            totalView.isHidden = false
            statusView.isHidden = false
            statusViewHeight.constant = 56
            statusViewTopConst.constant = 12
            
            switch myOrder!.status {
                
            case 0 :
                
                circleFilledRecieved.image = UIImage(named: "circle")
                circleFilledReady.image = UIImage(named: "circle")
                circleFilledDelivered.image = UIImage(named: "circle")
                
            case 1 :
                
                circleFilledRecieved.image = UIImage(named: "circle-filled")
                circleFilledReady.image = UIImage(named: "circle")
                circleFilledDelivered.image = UIImage(named: "circle")
                
            case 2 :
                
                circleFilledRecieved.image = UIImage(named: "circle-filled")
                circleFilledReady.image = UIImage(named: "circle-filled")
                circleFilledDelivered.image = UIImage(named: "circle")
                
            case 3 :
                
                circleFilledRecieved.image = UIImage(named: "circle-filled")
                circleFilledReady.image = UIImage(named: "circle-filled")
                circleFilledDelivered.image = UIImage(named: "circle-filled")
                
            case 4 :
                
                circleFilledSumbmitted.image = UIImage(named: "circle")
                circleFilledRecieved.image = UIImage(named: "circle")
                circleFilledReady.image = UIImage(named: "circle")
                circleFilledDelivered.image = UIImage(named: "circle")
                
            default:
                break
            }
            
            subtotalLabel.text = "\(myOrder!.subtotal) EGP"
            totalLabel.text = "\(myOrder!.total) EGP"
            deliveryTimeLabel.text = myOrder!.orderTime
            mobileNumberLabel.text = myOrder!.phone
            deliveryFeeLabel.text = "\(myOrder!.delivery)"
            pointsDiscountLabel.text = "\(myOrder!.discount)"
            addressLabel.text = detailedaddress
            
        } else {
            
            confirmButton.isHidden = false
            ProceedStackView.isHidden = false
            statusView.isHidden = true
            totalView.isHidden = true
            statusViewHeight.constant = 0
            statusViewTopConst.constant = 0
            tableViewHeight.constant = 150
            
            for mentItem in User.shared.cart {
                subtotal = subtotal + (Int(mentItem.price)! * mentItem.qty)
            }
            
            total = Double (subtotal) * discount/100
            
            deliveryFeeLabel.text = "\(15) EGP"
            pointsDiscountLabel.text = "\(discount)%"
            subtotalLabel.text = "\(subtotal) EGP"
            proceedLabel.text = "Total \(String((Double(subtotal) - total) + Double(deliveryFees)))"
            deliveryTimeLabel.text = orderTime
            mobileNumberLabel.text = phoneNumber
            addressLabel.text = detailedaddressConfirmAddress
        }
    }
    
    @IBAction func ConfirmButtonClicked(_ sender: UIButton) {
        
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
    
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to proceed the order?" , preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default) { (alert) in
                self.makeOrder()
        }
        
        self.dismissSVProgress()
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(isMyOrders){
            
            if(myOrder != nil){
                return myOrder!.dishesList.count
            } else {
                return 0
            }
            
        } else {
            return User.shared.cart.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SummaryCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        if (isMyOrders) {
            
            if(myOrder != nil) {
                
                let menuItem = myOrder!.dishesList[indexPath.row]
                cell.nameLabel.text = menuItem.id
    }
            
        } else {
            
            let menuItem = User.shared.cart[indexPath.row]
            let menuItem2 = User.shared.cart[indexPath.row]
            cell.nameLabel.text = menuItem.name
            cell.priceLabel.text = "\(Int(menuItem.price)! * menuItem.qty)"
            cell.qtyLabel.text = "\(menuItem.qty)"
            if (menuItem2.size == 0 && menuItem2.selectedOption1 == "" && menuItem2.selectedOption2 == "") {
                
                cell.sizeLabel.text = "Large"
                
            } else if (menuItem2.size == 1 && menuItem2.selectedOption1 == "" && menuItem2.selectedOption2 == ""){
                
                cell.sizeLabel.text = "\(menuItem2.selectedSize)"
                cell.priceLabel.text = "\(Int(menuItem2.price)! * menuItem2.qty)"
                
            } else if (menuItem2.size == 0 && menuItem2.selectedOption1 != "" && menuItem2.selectedOption2 != "") {
                
                cell.sizeLabel.text = "Large" + ", \(menuItem2.selectedOption1)" + ",and \(menuItem2.selectedOption2)"
                
            } else if (menuItem2.size == 0 && menuItem2.selectedOption1 != "") {
                
                cell.sizeLabel.text = "Large" + ", \(menuItem2.selectedOption1)"
                
            }
            
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

extension SummaryVC {
    
    func makeOrder(){
        
        DispatchQueue.main.async {
            
            var dishes = [[String:Any]]()
            var qties = [[String:Any]]()
            var i = 0
            
            for dish in self.dishList {
                
                dishes.append(["dishes[\(i)]" : dish["id"] as! Int])
                qties.append(["quantities[\(i)]" : dish["id"] as! Int])
                
                i = i + 1
            }
//            
            let params  = ["order_time": self.orderTime,
                           "creation_time": self.craetionTime,
                           "user_id": User.shared.id!,
                           "location": self.location,
                           "address_id": self.addressId,
                           "phone": self.phoneNumber,
                           "subtotal": self.subtotal,
                           "delivery": self.deliveryFees,
                           "discount": self.discount,
                           "total": self.subtotal + self.deliveryFees - Int(self.discount),
                           "dishes": dishes,
                           "quantities": qties,
                           "options" : "asd",
                           "sides1" : "asd",
                           "sides2" : "asd",
                           "sizes" : "asd",
                           "eta" : "asd",
                           "comment" : "asd",
                           "points" : "asd"] as [String: AnyObject]
                                

            let manager = Manager()
            manager.perform(serviceName: .makeOrder, parameters: params) { (JSON, error) -> Void in
              
                if(error != nil){
                    
                    self.dismissSVProgress()
                    self.displayAlertMessage(title: "Error", messageToDisplay: "Connection Error")
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    
                    if let loginResponse = jsonDict!["error"] as? Bool {
                        
                        if(loginResponse){
                            
                            self.dismissSVProgress()
//                            self.displayAlertMessage(title: "Error", messageToDisplay: "Connection Error")
                            
                        } else {
                            
                            self.dismissSVProgress()
                            User.shared.cart.removeAll()
                            User.shared.saveData()
                            appDelegate.setRoot(storyBoard: .main, vc: .home)
                        }
                    }
                }
            }
        }
    }
}
