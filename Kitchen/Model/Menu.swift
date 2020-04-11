//
//  Menu.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 2/18/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import Foundation
import ObjectMapper

class Menu : NSObject, Mappable, Codable, NSCoding {
    
    var id: Int = -1
    var name : String = ""
    var desc : String = ""
    var price : String = ""
    var likes: Int = 1
    var location: String = ""
    var type: String = ""
    var qty : Int = 1
    var image: String = ""
    var size: Int = -1
    var priceM: String = ""
    var priceL: String = ""
    var cost: String = ""
    var eta: String = ""
    var options1: String = ""
    var options2: String = ""
    var selectedOption1: String = ""
    var selectedOption2: String = ""
    var side1: String = ""
    var side2 : String = ""
    var selectedSize = ""
    
    required init?(map: Map) {
        
    }
    
    init(id: Int, name: String, price: String, likes: Int, location: String, type: String, qty : Int, desc : String, image: String, size: Int, priceM: String, priceL: String, cost: String, eta: String, options1: String, options2: String, selectedOption1: String, selectedOption2: String, side1: String, side2: String, selectedSize: String) {
        self.id = id
        self.name = name
        self.desc = desc
        self.price = price
        self.likes = likes
        self.location = location
        self.type = type
        self.qty = qty
        self.image = image
        self.size = size
        self.priceM = priceM
        self.priceL = priceL
        self.cost = cost
        self.eta = eta
        self.options1 = options1
        self.options2 = options2
        self.selectedOption1 = selectedOption1
        self.selectedOption2 = selectedOption2
        self.side1 = side1
        self.side2 = side2
        self.selectedSize = selectedSize
 
    }

    
    func mapping(map: Map) {
        
        id  <- map["dId"]
        name <- map["dishName"]
        desc <- map["dishDisc"]
        price <- map["priceL"]
        likes <- map["likes"]
        location <- map["location"]
        type <- map["type"]
        image <- map["imageUrl"]
        size <- map["size"]
        priceM <- map["priceM"]
        priceL <- map["priceL"]
        cost <- map["cost"]
        eta <- map["eta"]
        options1 <- map["options1"]
        options2 <- map["options2"]
        side1 <- map["sides1"]
        side2 <- map["sides2"]
        

    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let id = aDecoder.decodeInteger(forKey: "id")
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let desc = aDecoder.decodeObject(forKey: "desc") as! String
        let price = aDecoder.decodeObject(forKey: "price") as! String
        let likes = aDecoder.decodeInteger(forKey: "likes")
        let location = aDecoder.decodeObject(forKey: "location") as! String
        let type = aDecoder.decodeObject(forKey: "type") as! String
        let image = aDecoder.decodeObject(forKey: "image") as! String
        let qty = aDecoder.decodeInteger(forKey: "quantity")
        let size = aDecoder.decodeInteger(forKey: "size")
        let priceM = aDecoder.decodeObject(forKey: "priceM") as! String
        let priceL = aDecoder.decodeObject(forKey: "priceL") as! String
        let cost = aDecoder.decodeObject(forKey: "cost") as! String
        let eta = aDecoder.decodeObject(forKey: "eta") as! String
        let option1 = aDecoder.decodeObject(forKey: "options1") as! String
        let option2 = aDecoder.decodeObject(forKey: "options2") as! String
        let selectedOption1 = aDecoder.decodeObject(forKey: "selectedOption1") as! String
        let selectedOption2 = aDecoder.decodeObject(forKey: "selectedOption2") as! String
        let side1 = aDecoder.decodeObject(forKey: "side1") as! String
        let side2 = aDecoder.decodeObject(forKey: "side2") as! String
        let selectedSize = aDecoder.decodeObject(forKey: "selectedSize") as! String

        
        self.init(id: id, name: name, price: price, likes: likes, location: location, type: type, qty: qty, desc: desc,image: image, size: size, priceM: priceM, priceL: priceL, cost: cost, eta: eta, options1: option1, options2: option2, selectedOption1:selectedOption1 , selectedOption2: selectedOption2,side1: side1, side2: side2,selectedSize: selectedSize)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(desc, forKey: "desc")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(likes, forKey: "likes")
        aCoder.encode(location, forKey: "location")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(qty, forKey: "quantity")
        aCoder.encode(image, forKey: "image")
        aCoder.encode(size, forKey: "size")
        aCoder.encode(priceM, forKey: "priceM")
        aCoder.encode(priceL, forKey: "priceL")
        aCoder.encode(cost, forKey: "cost")
        aCoder.encode(eta, forKey: "eta")
        aCoder.encode(options1, forKey: "options1")
        aCoder.encode(options2, forKey: "options2")
        aCoder.encode(selectedOption1, forKey: "selectedOption1")
        aCoder.encode(selectedOption2, forKey: "selectedOption2")
        aCoder.encode(side1, forKey: "side1")
        aCoder.encode(side2, forKey: "side2")
        aCoder.encode(selectedSize, forKey: "selectedSize")

        
    }
}
