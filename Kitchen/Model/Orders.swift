//
//  Orders.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 6/16/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import Foundation
import ObjectMapper

class Orders : NSObject,Mappable {
    
    var orderId: Int = -1
    var creationTime : String = ""
    var orderTime : String = ""
    var status : Int = -1
    var location: String  = ""
    var phone: String = ""
    var subtotal: Int = -1
    var discount : Int = -1
    var total: Int = -1
    var delivery : Int = -1
    var dishesList = [dishes]()
    var address : AdressModel?
    var options : String = ""
    var sides1 : String = ""
    var sides2 : String = ""
    var sizes : String = ""
    var eta : String = ""
    var comment : String = ""
    var points : String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        orderId  <- map["orderId"]
        creationTime <- map["creation_time"]
        orderTime <- map["order_time"]
        status <- map["status"]
        location <- map["location"]
        phone <- map["phone"]
        subtotal <- map["subtotal"]
        discount <- map["discount"]
        total <- map["total"]
        dishesList <- map["dishesList"]
        address     <- map["address_id"]
        delivery <- map["delivery"]
        options <- map["options"]
        sides1 <- map["sides1"]
        sides2 <- map["sides2"]
        sizes <- map["sizes"]
        eta <- map["eta"]
        comment <- map["comment"]
        points <- map["points"]
    }
    
}

class dishes : NSObject,Mappable {

    var id : String = ""
    var quantity : String = ""

    required init?(map: Map) {

    }

    func mapping(map: Map) {

        id <- map["id"]
        quantity <- map["quantity"]


    }


}
