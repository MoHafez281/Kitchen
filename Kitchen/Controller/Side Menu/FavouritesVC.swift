//
//  Favourites.swift
//  Kershoman
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

class FavouritesVC: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var menuList = [Menu]()
    var allMenu : Menu?
    let host = "http://52.15.188.41/cookhouse/images/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//      Reload the view after checking the network connectivity and it is working
        NotificationCenter.default.addObserver(self, selector: #selector(FavouritesVC.functionName), name:NSNotification.Name(rawValue: "NotificationID"), object: nil)

        tableView.delegate = self
        tableView.dataSource = self
        
        AddToCartPopupVC.favButtonIsDiable = 2 //To check if user on FavouritesVC so favorite buton will be hidden, else if user on HomeMenuVC favorite button will be appear
                
        getFav(userId: User.shared.id!)
    }
    
//  Reload the view after checking the network connectivity and it is working
    @objc func functionName() {
        getFav(userId: User.shared.id!)
    }

    @IBAction func sideBarButtonPressed(_ sender: Any) {
        self.sideMenuController?.revealMenu()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FavouritesCell
        let dishes = menuList[indexPath.row]
        cell.favouritesNameLabel.text! = dishes.name
        cell.favouritesPriceLabel.text! = "\(dishes.price) EGP"
        
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
            let popupVC = segue.destination as! AddToCartPopupVC
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
}

extension FavouritesVC {
    
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
                    let favouritesResponse = jsonDict!["error"]
                    let favouritesMessage = jsonDict!["error_msg"]
                    
                    if (favouritesResponse as? Int == 1) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "", messageToDisplay: favouritesMessage as! String)
                        
                    } else {
                        
                        self.dismissSVProgress()
                        let menus = jsonDict!["dishes"]
                        self.menuList = Mapper<Menu>().mapArray(JSONObject: menus)!
                        self.tableView.reloadData()
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
                    let removeFavouritesError = jsonDict!["error"] as! Bool
                    let removeFavouritesMessage = jsonDict!["message"] as! String
                    
                    if (removeFavouritesError) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "", messageToDisplay: "\(removeFavouritesMessage)")
                        
                    } else {
                        
                        self.dismissSVProgress()
                    }
                }
            }
        }
    }
}
