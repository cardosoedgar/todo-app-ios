//
//  Task.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import Foundation
import ObjectMapper

class Task : Mappable {
    var id: Int?
    var name: String?
    
    class func newInstance(map: Map) -> Mappable? {
        return Task()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}