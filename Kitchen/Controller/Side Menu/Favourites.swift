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

class Favourites: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var menuList = [Menu]()
    var allMenu : Menu?
    var x : Int = 0
    let host = "http://52.15.188.41/cookhouse/images/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
          NotificationCenter.default.addObserver(self, selector: #selector(Favourites.functionName), name:NSNotification.Name(rawValue: "NotificationID"), object: nil)
        
        // Do any additional setup after loading the view.
        
        getFav(userId: User.shared.id!)

        tableView.delegate = self
        tableView.dataSource = self
    }
    
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
        x = dishes.id
        cell.favouritesPriceLabel.text! = "\(dishes.price)LE"
        
        if(dishes.image != "") {
            let imageUrl = dishes.image.replacingOccurrences(of: " ", with: "%20")
            let url = URL(string: host + imageUrl)
            
            if(url != nil) {
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            RemoveFromFav(userId: User.shared.id!, dishId: x)
            menuList.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}


extension Favourites {
    
    func getFav(userId: Int){
        DispatchQueue.main.async {
            
            let params  = ["user_id" : userId ] as [String: AnyObject]
            
            let manager = Manager()
            
            manager.perform(serviceName: .getFav, parameters: params) { (JSON, error) -> Void in
                
                if(error != nil){
                    // show error
                    self.noInternetConnection()
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let menusResponse = jsonDict!["error"]
                    let menusMessage = jsonDict!["error_msg"]
                    
                    if (menusResponse as? Int == 1) {
                        self.displayAlertMessage(title: "", messageToDisplay: menusMessage as! String)
                    } else {
                        let menus = jsonDict!["dishes"]
                        self.menuList = Mapper<Menu>().mapArray(JSONObject: menus)!
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func RemoveFromFav(userId: Int, dishId: Int){
        DispatchQueue.main.async {
            
            let params  = ["dish_id" : dishId ,"user_id" : userId ] as [String: AnyObject]
            
            let manager = Manager()
            
            manager.perform(serviceName: .removeFromFav, parameters: params) { (JSON, error) -> Void in
                
                if(error != nil){
                    self.noInternetConnection()
                }else {
                    let jsonDict = JSON as? NSDictionary
                    let jsonError = jsonDict!["error"] as! Bool
                    if(jsonError){
                        self.displayAlertMessage(title: "", messageToDisplay: "\(jsonError)")
                    }else{
                        self.displayAlertMessage(title: "", messageToDisplay: "Removed")
                        
                    }
                }
            }
        }
    }
}

