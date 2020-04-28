//
//  GetProfile.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 4/5/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import Foundation
import ObjectMapper

class GetProfile : NSObject, Mappable, Codable, NSCoding {
    
    var id: Int = -1
    var username : String = ""
    var email : String = ""
    var phone: String = ""
    var location: String = ""
    var birthday: String = ""
    var job: String = ""
    
    var discount: String = ""
    
    
    required init?(map: Map) {
        
    }
    
    init(id: Int , username: String , email: String , phone: String , location: String , birthday: String , job: String, discount: String) {
            self.id = id
            self.username = username
            self.email = email
            self.phone = phone
            self.location = location
            self.birthday = birthday
            self.job = job
        
            self.discount = discount
        }
    
    
    func mapping(map: Map) {
        
        id  <- map["id"]
        username <- map["username"]
        email <- map["email"]
        phone <- map["phone"]
        location <- map["location"]
        birthday <- map["birthday"]
        job <- map["job"]
        
        discount <- map["discount"]
        
    }
    
        required convenience init?(coder aDecoder: NSCoder) {
            let id = aDecoder.decodeInteger(forKey: "id")
            let username = aDecoder.decodeObject(forKey: "username") as! String
            let email = aDecoder.decodeObject(forKey: "email") as! String
            let phone = aDecoder.decodeObject(forKey: "phone") as! String
            let location = aDecoder.decodeObject(forKey: "location") as! String
            let birthday = aDecoder.decodeObject(forKey: "birthday") as! String
            let job = aDecoder.decodeObject(forKey: "job") as! String
            
            let discount = aDecoder.decodeObject(forKey: "discount") as! String
            
            self.init(id: id , username: username, email: email, phone: phone, location: location , birthday: birthday , job: job, discount: discount)
        }
    
        func encode(with aCoder: NSCoder) {
            aCoder.encode(id, forKey: "id")
            aCoder.encode(username, forKey: "username")
            aCoder.encode(email, forKey: "email")
            aCoder.encode(phone, forKey: "phone")
            aCoder.encode(location, forKey: "location")
            aCoder.encode(birthday, forKey: "birthday")
            aCoder.encode(job, forKey: "job")
            
            aCoder.encode(discount, forKey: "discount")

        }
    
    
}

