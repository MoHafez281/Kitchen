//
//  MyOrders.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 4/6/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import SideMenuSwift
import Alamofire
import SwiftyJSON
import ObjectMapper
import SVProgressHUD

class MyOrders: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var getorderList = [Orders]()
//    var getOrderQty = [dishes]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Reload the view after checking the network connectivity and it is working
        NotificationCenter.default.addObserver(self, selector: #selector(MyOrders.functionName), name:NSNotification.Name(rawValue: "NotificationID"), object: nil)
        
        getOrder()
    }
    
    //Reload the view after checking the network connectivity and it is working
    @objc func functionName() {
        getOrder()
    }
    
    @IBAction func sideBarButtonPressed(_ sender: Any) {
        self.sideMenuController?.revealMenu()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "summary") {
            let vc = segue.destination as! SummaryVC
            
            vc.isMyOrders = true
            if let order = sender as? Orders {
                vc.myOrder = order
//                vc.total = order.total
                vc.orderTime = order.orderTime
                vc.detailedaddress = (order.address!.fullAddress) + ", " + (order.address!.street) + ", " + (order.address!.landmark) + ", " + (order.address!.area) + ", " + (order.address!.buldingNumber) + ", " + (order.address!.floor) + ", " + (order.address!.aparmentNumber)
                vc.phoneNumber = order.phone
                vc.subtotal = order.subtotal
                vc.deliveryFees = order.delivery
                vc.discount = Double(order.discount)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return getorderList.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyOrdersCell
        let orders = getorderList[indexPath.row]
        cell.creationTimeLabel.text = orders.orderTime
        cell.orderNumberLabel.text = "\(orders.orderId)"
        switch orders.status {
        case 0 :
            cell.statusLabel.text = " Waiting "
            cell.statusLabel.backgroundColor = #colorLiteral(red: 0.1921568627, green: 0.5921568627, blue: 0.9450980392, alpha: 1)
        case 1 :
            cell.statusLabel.text = " Cooking "
            cell.statusLabel.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.7529411765, blue: 0.2705882353, alpha: 1)

        case 2 :
            cell.statusLabel.text = " Delivered "
            cell.statusLabel.backgroundColor = #colorLiteral(red: 0.3176470588, green: 0.6901960784, blue: 0.3137254902, alpha: 1)

        case 3 :
            cell.statusLabel.text = " Cancelled "
            cell.statusLabel.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.2509803922, blue: 0.2, alpha: 1)

        default:
            break
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.isNavigationBarHidden = true
        performSegue(withIdentifier: "summary", sender: getorderList[indexPath.row])
        
    }
    
}

extension MyOrders {
    
    func getOrder() {
        
        DispatchQueue.main.async {
            
            let params  = ["user_id" : User.shared.id] as [String: AnyObject]
            let manager = Manager()
            manager.perform(methodType: .post, serviceName: .getUserOrders ,  parameters: params) { (JSON, error) -> Void in
                
                if (error != nil) {

                    self.displayAlertMessage(title: "Error", messageToDisplay: "Connection Error")
                    self.dismissSVProgress()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let authCodeResponse = jsonDict!["error"]
                    let authCodeMessage = jsonDict?["message"]
                    
                    if (authCodeResponse as? Int == 1) {

                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: authCodeMessage as! String)
                        
                    } else {
                        
                        let menus = jsonDict!["orders"]
                        //self.getorderList = Mapper<Orders>().mapArray(JSONObject: menus)!
                        self.tableView.reloadData()
                        self.dismissSVProgress()
                    }
                }
            }
        }
    }
}
