//
//  List.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import Foundation
import ObjectMapper

class List : Mappable {
    var id: Int?
    var name: String?
    var tasks: [Task]?
    
    class func newInstance(map: Map) -> Mappable? {
        return List()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        tasks <- map["Tasks"]
    }
}