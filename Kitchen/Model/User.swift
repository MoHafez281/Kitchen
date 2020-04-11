//
//  User.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 2/22/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import Foundation
import ObjectMapper

class User: NSObject, Mappable, Codable, NSCoding {
    
    static let shared = User()

    var createdAt : String?
    var name : String?
    var email : String?
    var token : String?
    var id : Int?
    var phone : String?
    var birthday : String?
    var location: String?
    var job: String?
    var address: String?
    var cart = [Menu]()
    var profile = [GetProfile]()
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        self.name      <- map["user.username"]
        self.email       <- map["user.email"]
        self.token    <- map["user.apiKey"]
        self.createdAt  <- map["user.createdAt"]
        self.id         <- map["user.id"]
        self.phone      <- map["user.phone"]
        self.birthday   <- map["user.birthday"]
        self.location   <- map["user.location"]
        self.job        <- map["user.job"]
        self.address <- map["user.address"]
    }
    
    
    func fillUserModel(model: User) {
        
        self.name      = model.name
        self.email       = model.email
        self.token    = model.token
        self.createdAt = model.createdAt
        self.id = model.id
        self.phone = model.phone
        self.birthday = model.birthday
        self.location = model.location
        self.job = model.job
        self.address = model.address
        
    }
    
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        
        User.shared.name       = aDecoder.decodeObject(forKey: "name") as? String
        User.shared.email        = aDecoder.decodeObject(forKey: "email") as? String
        User.shared.token     = aDecoder.decodeObject(forKey: "token") as? String
        User.shared.createdAt = aDecoder.decodeObject(forKey: "createdAt") as? String
        User.shared.id = aDecoder.decodeObject(forKey: "id") as? Int
        User.shared.phone = aDecoder.decodeObject(forKey: "phone") as? String
        User.shared.birthday = aDecoder.decodeObject(forKey: "birthday") as? String
        User.shared.location = aDecoder.decodeObject(forKey: "location") as? String
        User.shared.job = aDecoder.decodeObject(forKey: "job") as? String
        User.shared.address = aDecoder.decodeObject(forKey: "address") as? String
        if let cart = aDecoder.decodeObject(forKey: "cart") as? [Menu] {
            User.shared.cart = cart

        }
    }
    
    
    func encode(with coder: NSCoder) {
        
        coder.encode(name, forKey: "name")
        coder.encode(email, forKey: "email")
        coder.encode(token, forKey: "token")
        coder.encode(id, forKey: "id")
        coder.encode(phone, forKey: "phone")
        coder.encode(birthday, forKey: "birthday")
        coder.encode(location, forKey: "location")
        coder.encode(job, forKey: "job")
        coder.encode(cart, forKey: "cart")
        coder.encode(cart, forKey: "address")

    }
    
    
    func loadData(){
        let userDefaults = UserDefaults.standard
        NSKeyedUnarchiver.unarchiveObject(with: (userDefaults.object(forKey: "User") as! NSData) as Data)
    }
    
    
    func saveData(){
        print("self:\(self)")
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(data, forKey: "User")
    }
    
    
    func isRegistered() -> Bool{
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "IsRegistered")
    }
    
    
    func setIsRegister(registered: Bool){
        let defaults = UserDefaults.standard
        defaults.set(registered, forKey: "IsRegistered")
    }
    
    func apiToken() -> String {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "token") != nil{
            return defaults.string(forKey: "token")!
        }
        else{
            return ""
        }
    }
    
    func setApiToken(token: String?){
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: "token")
    }
    
    
    func logout() {
        
        self.name      = nil
        self.email       = nil
        self.token    = nil
        self.phone = nil
        self.createdAt = nil
        self.setApiToken(token: nil)
        self.setIsRegister(registered: false)
        self.address = nil
        
        User.shared.cart = [Menu]()
        User.shared.saveData()
        
    }
    
    func emptyCart () {
        User.shared.cart = [Menu]()
    }
    
}

