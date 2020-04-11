//
//  AddressModel.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 4/22/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import Foundation
import Foundation
import ObjectMapper

class AdressModel : NSObject,Mappable {
    
    var id: Int = -1
    var addressName : String = ""
    var fullAddress : String = ""
    var floor : String = ""
    var aparmentNumber: String  = ""
    var buldingNumber: String = ""
    var area: String = ""
    var street : String = ""
    var landmark: String = ""
    var lat: String = ""
    var lon: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        id  <- map["id"]
        addressName <- map["addressName"]
        fullAddress <- map["fullAddress"]
        floor <- map["floor"]
        aparmentNumber <- map["apartmentNumber"]
        buldingNumber <- map["buildingNumber"]
        area <- map["area"]
        street <- map["street"]
        landmark <- map["landMark"]
        lat <- map["latitude"]
        lon <- map["longitude"]
    
    }
    
    func setIsRegister2(registered: Bool){
         let defaults = UserDefaults.standard
         defaults.set(registered, forKey: "IsRegistered2")
     }
    
    func setApiToken2(token: String?){
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: "token")
    }
    
//    func logout2() {
//        
//        self.addressName      = ""
//        self.fullAddress       = ""
//        self.floor    = ""
//        self.aparmentNumber = ""
//        self.buldingNumber = ""
//        self.area      = ""
//        self.street       = ""
//        self.landmark    = ""
//        self.lat = ""
//        self.lon = ""
//        self.setIsRegister2(registered: false)
//        self.setApiToken2(token: nil)
//        User.shared.saveData()
//        
//    }
    
}
