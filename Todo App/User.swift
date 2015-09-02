//
//  User.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//
import ObjectMapper
import Foundation

class User: Mappable {
    var id: String?
    var email: String?
    var name: String?
    var token: String?
    
    class func newInstance(map: Map) -> Mappable? {
        return User()
    }
    
    func mapping(map: Map) {
        id <- map["user.id"]
        name <- map["user.name"]
        email <- map["user.email"]
        token <- map["token"]
    }
}