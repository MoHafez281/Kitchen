//
//  Manager.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 2/18/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import Alamofire

let hostName = "http://52.15.188.41/cookhouse/public/index.php/"

enum ServiceName: String {
    
    case login = "login"
    case getMenu = "get_menu"
    case register = "register"
    case addToFavourite = "add_to_favorite"
    case removeFromFav = "remove_from_favorite"
    case checkIfFav = "check_if_favorite"
    case getFav = "get_favorite"
    case getProfile = "get_profile"
    case updateUser = "update_user"
    case addAddress = "add_address"
    case getAddress = "get_addresses"
    case updatePassword = "update_password"
    case makeOrder = "add_order"
    case authCode = "confirm_phone_code"
    case forgotPasswordAuthCode = "confirm_password_code"
    case getUserOrders = "get_orders"
    case promoCode = "check_promocode"
    case getUserPoints = "get_user_points"
    case getcategories = "get_categories"
}

class Manager {
    
    func perform(methodType: HTTPMethod = .post, useCustomeURL: Bool = false, urlStr: String = "", serviceName: ServiceName, parameters: [String: AnyObject]? = nil, completionHandler: @escaping (Any?, String?) -> Void)-> Void {
        
        var urlString: String = ""
        var headers: HTTPHeaders? = nil
        
        if useCustomeURL {
            urlString = urlStr
        }else {
            urlString = "\(hostName)\(serviceName.rawValue)"
        }
        
        print("ServiceName:\(serviceName)  parameters: \(String(describing: parameters))")
        
        //        if User.shared.token != "" && User.shared.token != nil{
        //            headers = [
        //                "X-localization": Locale.preferredLanguages[0],
        //                "Authorization": "Bearer \(User.shared.token!)"
        //            ]
        //        }else{
        //            headers = [
        //                "X-localization": Locale.preferredLanguages[0]
        //            ]
        //        }
        //
        
        Alamofire.request(urlString, method: methodType, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON{ response in
            
            
            debugPrint(response)
            
            if response.result.isSuccess {
                
                if let dict = response.result.value! as? [String: Any] {
                    completionHandler(dict,nil)
                }else {
                    completionHandler(nil,"Error has accoured.")
                }
                
                //                if dict["value"] as? Bool == true || dict["value"] as? String == "true" {
                //                    completionHandler(dict, nil)
                //                }else{
                //                    if let dictError = dict["error"] as? String {
                //                        completionHandler(nil, dictError)
                //                    }else {
                //                        guard let errorStr = dict["msg"] as? String else {
                //                            let errorsDict = dict["msg"] as! [String: Any]
                //                            let errorsArr = errorsDict.values.first as! [String]
                //
                //                            completionHandler(nil, errorsArr[0])
                //                            return
                //                        }
                //                        completionHandler(nil, errorStr)
                //                    }
                //                }
                //
            } else { //FAILURE
                print("error \(String(describing: response.result.error)) in serviceName: \(serviceName)")
                completionHandler(nil, response.result.error?.localizedDescription)
            }
        }
    }
}
