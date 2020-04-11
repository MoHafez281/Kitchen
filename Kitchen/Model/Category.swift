//
//  Category.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 2/14/20.
//  Copyright © 2020 Mohamed Hafez. All rights reserved.
//

import Foundation
import ObjectMapper

class Category : Mappable {

    var id : Int = -1
    var title : String = ""

    required init?(map: Map) {

    }

    func mapping(map: Map) {

        id    <- map["id"]
        title <- map["category"]

    }


}
