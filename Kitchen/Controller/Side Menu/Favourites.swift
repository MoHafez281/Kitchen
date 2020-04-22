//
//  Favourites.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 3/27/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper
import Kingfisher
import Alamofire
import SideMenuSwift
import SVProgressHUD

class Favourites: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var menuList = [Menu]()
    var allMenu : Menu?
    let host = "http://52.15.188.41/cookhouse/images/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reload the view after checking the network connectivity and it is working
        NotificationCenter.default.addObserver(self, selector: #selector(Favourites.functionName), name:NSNotification.Name(rawValue: "NotificationID"), object: nil)

        tableView.delegate = self
        tableView.dataSource = self
        
        getFav(userId: User.shared.id!)
    }
    
    //Reload the view after checking the network connectivity and it is working
    @objc func functionName() {
        getFav(userId: User.shared.id!)
    }

    @IBAction func sideBarTapped(_ sender: Any) {
        self.sideMenuController?.revealMenu()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FavouritesCell
        let dishes = menuList[indexPath.row]
        cell.favouritesNameLabel.text! = dishes.name
        cell.favouritesPriceLabel.text! = "\(dishes.price)LE"
        
        if (dishes.image != "") {
            
            let imageUrl = dishes.image.replacingOccurrences(of: " ", with: "%20")
            let url = URL(string: host + imageUrl)
            
            if (url != nil) {
                cell.favouritesImage.kf.setImage(with: url)
            }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        allMenu = menuList[indexPath.item]
        self.performSegue(withIdentifier: "InfoView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "InfoView" {
            let popupVC = segue.destination as! Popup2ViewController
            popupVC.allMenuPopup = allMenu
            tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let dishes = menuList[indexPath.row]
        if editingStyle == .delete {
            
            RemoveFromFav(userId: User.shared.id!, dishId: dishes.id)
            menuList.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
//  For making Tableview reload with animation
    func animateRows() {
        let cells = tableView.visibleCells
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableView.frame.height)
        }
        var delay = 0.0
        for cell in cells {
            UIView.animate(withDuration: 1, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                cell.transform = .identity
            })
            delay += 0.05
        }
    }
}

extension Favourites {
    
    func getFav(userId: Int) {
        
        showSVProgress()
        DispatchQueue.main.async {
            
            let params  = ["user_id" : userId ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .getFav, parameters: params) { (JSON, error) -> Void in
                
                if (error != nil) {
                    
                    self.noInternetConnection()
                    self.dismissSVProgress()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let menusResponse = jsonDict!["error"]
                    let menusMessage = jsonDict!["error_msg"]
                    
                    if (menusResponse as? Int == 1) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "", messageToDisplay: menusMessage as! String)
                        
                    } else {
                        
                        self.dismissSVProgress()
                        let menus = jsonDict!["dishes"]
                        self.menuList = Mapper<Menu>().mapArray(JSONObject: menus)!
                        self.tableView.reloadData()
                        self.animateRows()
                    }
                }
            }
        }
    }
    
    func RemoveFromFav(userId: Int, dishId: Int) {
        
        showSVProgress()
        DispatchQueue.main.async {
            
            let params  = ["dish_id" : dishId ,"user_id" : userId ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .removeFromFav, parameters: params) { (JSON, error) -> Void in
                
                if (error != nil) {
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let jsonError = jsonDict!["error"] as! Bool
                    let jsonMessage = jsonDict!["message"] as! String
                    
                    if (jsonError) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "", messageToDisplay: "\(jsonMessage)")
                        
                    } else {
                        
                        self.dismissSVProgress()
                    }
                }
            }
        }
    }
}
