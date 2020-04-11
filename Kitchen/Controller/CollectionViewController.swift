//
//  CollectionViewController.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 1/6/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import Kingfisher
import SideMenuSwift
import AlamofireImage
import SwiftyJSON
import ObjectMapper
import ImageSlideshow

class CollectionViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var categoryCV: UICollectionView!
    @IBOutlet weak var cartButton: UIBarButtonItem!
    @IBOutlet weak var imageSlider: ImageSlideshow!
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var menuCV: UICollectionView!
    @IBOutlet weak var test: UIBarButtonItem!
    @IBOutlet weak var dropDownMenuIcon: UIView!
    
        
    var menuList = [Menu]()
    var dishesArray = [AnyObject]()
    var selectedMenu : String = ""
    var selectedLocation : String?
    var allMenu : Menu?
    let host = "http://52.15.188.41/cookhouse/images/"
    let location = ["", "October", "Dokki", "Giza" , "Nasr City" , "Smart Village" , "Zamalek" , "Agouza" , "Maadi"]
    var x : String = ""
    var dishType2 = ""
    var categoryList = [Category]()
    var selectedCategory : Category?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropDownMenuIcon.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(CollectionViewController.functionName), name:NSNotification.Name(rawValue: "NotificationID"), object: nil)
        
        navigationController?.navigationBar.barTintColor = UIColor.orange
        
        self.navigationController?.isNavigationBarHidden = true
        imageSlider.setImageInputs([ AlamofireSource(urlString: host + "food.jpeg" )!,
                                     AlamofireSource(urlString: host + "pizza.jpg" )!,
                                     AlamofireSource(urlString: host + "fruits.jpg" )!,
                                     AlamofireSource(urlString: host + "candy.jpg" )! ])
        imageSlider.slideshowInterval = 5
        
        menuCV.dataSource = self
        menuCV.delegate = self
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerTextField.inputView = pickerView
        pickerTextField.isEnabled = false
        pickerTextField.text = "Available in Maadi Only, Coming Soon"
        
        getCategories()
        
    }
    
    @objc func functionName() {
        getCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(User.shared.cart.count > 0){
            cartButton.image = #imageLiteral(resourceName: "cart-filled")
        } else {
            cartButton.image = #imageLiteral(resourceName: "cart")
        }
        navigationController?.setNavigationBarHidden(false, animated: false)
    
    }
    
    @IBAction func menuButton(_ sender: Any) {
        self.sideMenuController?.revealMenu()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.menuCV){
            return menuList.count
        } else {
            return categoryList.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == menuCV){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
            let dishes = menuList[indexPath.item]
            
            cell.kitchenLabelView.text! = dishes.name
            cell.priceLabelView.text! = "\(dishes.price)LE"
            cell.likesLabelView.text! = "\(dishes.likes)"
            
            if(dishes.image != "") {
                
                let imageUrl = dishes.image.replacingOccurrences(of: " ", with: "%20")
                let url = URL(string: host + imageUrl)
                
                if(url != nil){
                    cell.kitchenImageView.kf.setImage(with: url)
                }
            }
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoryCVCell
            
            let category = categoryList[indexPath.item]
            cell.title.text = category.title
            
            if(selectedCategory != nil){
                if(selectedCategory!.id == category.id){
                    cell.title.textColor = #colorLiteral(red: 0.9581589103, green: 0.4826408029, blue: 0.2752729356, alpha: 1)
                    cell.underlineView.backgroundColor = #colorLiteral(red: 0.9581589103, green: 0.4826408029, blue: 0.2752729356, alpha: 1)
                }else{
                    cell.title.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                    cell.underlineView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == menuCV){
        let cell = collectionView.cellForItem(at: indexPath)
        
        allMenu = menuList[indexPath.item]
            self.performSegue(withIdentifier: "InfoView", sender: self)
        }else{
            self.selectedCategory = categoryList[indexPath.item]
            self.categoryCV.reloadData()
            self.getMenu()
        }
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == menuCV){
            return CGSize(width: (collectionView.frame.width - 30) / 2 , height: 210)
        }else{
            return CGSize(width: 100, height: 40)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "InfoView" {
            
            let popupVC = segue.destination as! Popup2ViewController
            popupVC.allMenuPopup = allMenu
            popupVC.reloadView = { (Bool) in
                
                if(Bool){
                    if(User.shared.cart.count > 0){
                        self.cartButton.image = #imageLiteral(resourceName: "cart-filled")
                    } else {
                        self.cartButton.image = #imageLiteral(resourceName: "cart")
                    }
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                    self.getMenu()
                }
            }
        }
    }
}

extension CollectionViewController : UIPickerViewDelegate , UIPickerViewDataSource {
    
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
        
        if selectedLocation == "Maadi" {
            //Maadi selected
        } else {
            let alert = UIAlertController(title: "", message: "Available in Maadi Only, Coming Soon" , preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            selectedLocation = "Maadi"
        }
        pickerTextField.text = selectedLocation
        getMenu()
    }
    
}

extension CollectionViewController {
    
    func getMenu(){
        
        DispatchQueue.main.async {
            
            let params  = ["category" : self.selectedCategory!.id ,"location" : self.selectedLocation ?? "Maadi"] as [String: AnyObject]
            
            let manager = Manager()
            manager.perform(serviceName: .getMenu, parameters: params) { (JSON, error) -> Void in
                
                if(error != nil){
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let menusResponse = jsonDict!["error"]
                    let menusMessage = jsonDict!["message"]
                    
                    if (menusResponse as? Int == 1) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: menusMessage as! String)
                        
                    } else {
                        
                        let menus = jsonDict!["dishes"]
                        self.menuList = Mapper<Menu>().mapArray(JSONObject: menus)!
                        self.menuCV.reloadData()
                        if(self.menuList.count > 0){
                            self.menuCV.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                        }
                    }
                }
            }
        }
    }
}

extension CollectionViewController {
    
    func getCategories() {
        
        DispatchQueue.main.async {
            
            //let params  = [:] as [String: AnyObject]
            let manager = Manager()
            manager.perform(methodType: .get, serviceName: .getcategories ,  parameters: nil) { (JSON, error) -> Void in
                
                if(error != nil){
                    
                    self.dismissSVProgress()
                    // self.displayAlertMessage(title: "Error", messageToDisplay: "Connection Error")
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let categoriesResponse = jsonDict!["error"]
                    let categoriesMessage = jsonDict?["message"]
                    let categories = jsonDict?["categories"]
                    
                    if (categoriesResponse as? Int == 1) {
                        self.displayAlertMessage(title: "Error", messageToDisplay: categoriesMessage as! String)
                    }
                    else {
                        
                        let categoyArray = Mapper<Category>().mapArray(JSONObject: categories)!
                        
                        self.categoryList = categoyArray
                        
                        if(self.categoryList.count > 0){
                            self.selectedCategory = self.categoryList[0]
                            self.getMenu()
                        }
                        
                        self.categoryCV.reloadData()
                        
                    }
                }
            }
        }
    }
}



