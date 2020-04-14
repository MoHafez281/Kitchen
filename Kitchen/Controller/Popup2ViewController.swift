//
//  Popup2ViewController.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 3/11/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import DLRadioButton


class Popup2ViewController: UIViewController {
    
    @IBOutlet weak var largeButton: DLRadioButton!
    @IBOutlet weak var mediumButton: DLRadioButton!
    @IBOutlet weak var sizeView: UIView!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var options1View: UIView!
    @IBOutlet weak var options2View: UIView!
    @IBOutlet weak var options1TitleLabel: UILabel!
    @IBOutlet weak var options2TitleLabel: UILabel!
    @IBOutlet weak var option1TF: UITextField!
    @IBOutlet weak var options2TF: UITextField!
    @IBOutlet weak var addToCartButton: UIButton!
    
    let host = "http://52.15.188.41/cookhouse/images/"
    var reloadView : ((_ data: Bool) -> ())?
    var x : Int = 1
    var allMenuPopup : Menu?
    var t = Date() //for time
    var optoions1PickerView = UIPickerView()
    var optionss2PickerView = UIPickerView()
    var options1List = [String]()
    var options2List = [String]()
    var options1isSize = false
    var selectedPrice = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.favouriteButton.tintColor = #colorLiteral(red: 0.9019607843, green: 0.4941176471, blue: 0.1333333333, alpha: 1)
        quantityLabel.text = "\(x)"
        
//        for menuItem in User.shared.cart {
//            if(menuItem.id == allMenuPopup!.id){
//                allMenuPopup = menuItem
//            }
//        }
//
        if (allMenuPopup != nil) {
            
            selectedPrice = Int(allMenuPopup!.price)!

            nameLabel.text! = allMenuPopup!.name
            priceLabel.text! = "\(allMenuPopup!.price) EGP"
            descriptionLabel.text! = allMenuPopup!.desc
            quantityLabel.text = "\(allMenuPopup!.qty)"
            x = allMenuPopup!.qty
            totalLabel.text = "\(selectedPrice * allMenuPopup!.qty ) EGP"
            
            if(User.shared.isRegistered()) {
                checkIfFav(userId: User.shared.id!, dishId: allMenuPopup!.id)
            } else {
                favouriteButton.setImage(#imageLiteral(resourceName: "fav-unfilled"), for: .normal)
            }
            
            if(allMenuPopup!.image != "") {
                let imageUrl = allMenuPopup!.image.replacingOccurrences(of: " ", with: "%20")
                let url = URL(string: host + imageUrl)
                
                if(url != nil) {
                    imageview.kf.setImage(with: url)
                }
            }
            
            if(allMenuPopup!.side1 != "") {
                
                options1List = allMenuPopup!.side1.components(separatedBy: ",")
                option1TF.inputView = optoions1PickerView
                optoions1PickerView.delegate = self
                optoions1PickerView.dataSource = self
                User.shared.saveData()
                
                if (allMenuPopup!.side1 == "Pasta Red Sauce" ) {
                
                    options2View.removeFromSuperview()
                } else {
                    
                    if(allMenuPopup!.side2 != "" ){
                        options2List = allMenuPopup!.side2.components(separatedBy: ",")
                        options2TF.inputView = optionss2PickerView
                        optionss2PickerView.delegate = self
                        optionss2PickerView.dataSource = self
                    } else {
                        options2View.removeFromSuperview()
                    }
                }
                
            } else {
                options1View.removeFromSuperview()
                options2View.removeFromSuperview()
            }
            
            if(allMenuPopup!.size == 1) {
                largeButton.isSelected = true
                allMenuPopup!.selectedSize = "Large"
                User.shared.saveData()
            } else {
                sizeView.removeFromSuperview()
            }
            
        }
    }
    
    @IBAction func sizeButtonClicked(_ sender: DLRadioButton) {
        if(sender == mediumButton){

            priceLabel.text = allMenuPopup!.priceM + " EGP"
            selectedPrice = Int(allMenuPopup!.priceM)!
            totalLabel.text = "\(selectedPrice * allMenuPopup!.qty) EGP"
            allMenuPopup!.selectedSize = "Medium"
        }else{
            priceLabel.text = allMenuPopup!.priceL + " EGP"
            selectedPrice = Int(allMenuPopup!.priceL)!
            totalLabel.text = "\(selectedPrice * allMenuPopup!.qty) EGP"
            allMenuPopup!.selectedSize = "Large"
        }
            User.shared.saveData()
    }
    
    @IBAction func dismissPopup(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func favButtonPressed(_ sender: UIButton) {
        
        if(User.shared.isRegistered()) {
            
            if(favouriteButton.tag == 100) {
                // isFav
                favouriteButton.setImage(#imageLiteral(resourceName: "fav-unfilled"), for: .normal)
                favouriteButton.tag = 50
                
                if(allMenuPopup != nil && User.shared.id != nil) {
                    addOrRemoveToFav(remove: true, userId: User.shared.id!, dishId: allMenuPopup!.id)
                }
                
            } else if(favouriteButton.tag == 50) {
                //unFav
                favouriteButton.setImage(#imageLiteral(resourceName: "fav-filled"), for: .normal)
                favouriteButton.tag = 100
                
                if(allMenuPopup != nil && User.shared.id != nil) {
                    addOrRemoveToFav(remove: false, userId: User.shared.id!, dishId: allMenuPopup!.id)
                }
            }
            
        } else {
            let alert = UIAlertController(title: "", message: "You must login first." , preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func addToCartPressed(_ sender: UIButton) {
        
        if (allMenuPopup!.side1 != "" && allMenuPopup!.side2 != "") {
            
            if (option1TF!.text == "" || options2TF!.text == "") {
                displayAlertMessage(title: "Error", messageToDisplay: "You have to choose your sides!")
            } else {
                savedSelectedItems()
            }
        } else if (allMenuPopup!.side1 != "") {
            if (option1TF!.text == "" && (options2View == nil)) {
                displayAlertMessage(title: "Error", messageToDisplay: "You have to choose your sides!")
            } else {
                savedSelectedItems()
            }
        } else {
            savedSelectedItems()
        }
    }
    
    func savedSelectedItems() {
        if(allMenuPopup != nil) {
            var i = 0
            for menuItem in User.shared.cart {
                
                if(menuItem.id == allMenuPopup!.id && menuItem.selectedSize == allMenuPopup!.selectedSize && menuItem.selectedOption1 == allMenuPopup!.selectedOption1 && menuItem.selectedOption2 == allMenuPopup!.selectedOption2) {
                    i = i + 1
                    menuItem.qty = allMenuPopup!.qty
                    menuItem.price = "\(self.selectedPrice)"
                    User.shared.saveData()
                }
            }
            
            if(i == 0) {
                let item = Menu(id: allMenuPopup!.id, name: allMenuPopup!.name, price: allMenuPopup!.price, likes: allMenuPopup!.likes, location: allMenuPopup!.location, type: allMenuPopup!.type, qty: allMenuPopup!.qty, desc: allMenuPopup!.desc, image: allMenuPopup!.image, size: allMenuPopup!.size, priceM: allMenuPopup!.priceM, priceL: allMenuPopup!.priceL, cost: allMenuPopup!.cost, eta: allMenuPopup!.eta, options1: allMenuPopup!.options1, options2: allMenuPopup!.options2, selectedOption1: allMenuPopup!.selectedOption1, selectedOption2: allMenuPopup!.selectedOption2, side1: allMenuPopup!.side1, side2: allMenuPopup!.side2, selectedSize: allMenuPopup!.selectedSize)
                User.shared.cart.append(item)
                User.shared.saveData()
            }
            self.reloadView?(true)
        }
        dismiss(animated: true)
    }
    
    @IBAction func increment(_ sender: Any) {
        
        x = x + 1
        quantityLabel.text = "\(x)"
        if(allMenuPopup != nil) {
            allMenuPopup!.qty = x
            totalLabel.text = "\(selectedPrice * x ) EGP"
        }
    }
    
    @IBAction func decrment(_ sender: Any) {
        
        if x > 1 {
            x = x - 1
            quantityLabel.text = "\(x)"
            if (allMenuPopup != nil) {
                allMenuPopup!.qty = x
                totalLabel.text = "\(selectedPrice * x ) EGP"
            }
        }
    }
}

extension Popup2ViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == optoions1PickerView) {
            return options1List.count
        } else if(pickerView == optionss2PickerView) {
            return options2List.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == optoions1PickerView) {
            return options1List[row]
        } else if(pickerView == optionss2PickerView) {
            return options2List[row]
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == optoions1PickerView){
            
            allMenuPopup!.selectedOption1 = options1List[row]
            option1TF.text = options1List[row]
            if (option1TF!.text == "Pasta Red Sauce") {
                           
                options2View!.removeFromSuperview()
            } else if (option1TF!.text == "Pasta White Sauce") {
                options2View!.removeFromSuperview()
            } else {
                options2View.addSubview(sizeView)
            }
        }else if(pickerView == optionss2PickerView){
            allMenuPopup!.selectedOption2 = options2List[row]
            options2TF.text = options2List[row]
        }
        User.shared.saveData()
    }
}

extension Popup2ViewController {
    
    func checkIfFav(userId: Int, dishId: Int){
        DispatchQueue.main.async {
            
            let params  = ["dish_id" : dishId ,"user_id" : userId ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .checkIfFav, parameters: params) { (JSON, error) -> Void in
                
                if(error != nil) {
                    
                    self.favouriteButton.setImage(#imageLiteral(resourceName: "fav-unfilled"), for: .normal)
                    self.favouriteButton.tag = 50
                    
                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let isFav = jsonDict!["favorite"] as! Bool
                    if(isFav) {
                        self.favouriteButton.setImage(#imageLiteral(resourceName: "fav-filled"), for: .normal)
                        self.favouriteButton.tag = 100
                    } else {
                        self.favouriteButton.setImage(#imageLiteral(resourceName: "fav-unfilled"), for: .normal)
                        self.favouriteButton.tag = 50
                    }
                }
            }
        }
    }
    
    func addOrRemoveToFav(remove: Bool,userId: Int, dishId: Int){
        DispatchQueue.main.async {
            
            let params  = ["dish_id" : dishId ,"user_id" : userId ] as [String: AnyObject]
            let manager = Manager()
            var servicename : ServiceName = .addToFavourite
            
            if(remove) {
                servicename = .removeFromFav
            }
            manager.perform(serviceName: servicename, parameters: params) { (JSON, error) -> Void in
                
                if(error != nil) {
                    print("Error: " + error!)
                } else {
                    let jsonDict = JSON as? NSDictionary
                    let jsonError = jsonDict!["error"] as! Bool
                    if(jsonError){
                        print("Error")
                    } else {
                        self.reloadView?(true)
                    }
                }
            }
        }
    }
}
