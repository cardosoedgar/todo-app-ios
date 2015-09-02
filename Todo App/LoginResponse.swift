//
//  LoginResponse.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//
import Foundation
import ObjectMapper

class LoginResponse: Mappable {
    var message: String?
    var success: Bool?
    var token: String?
    var lists: [List]?
    var user: User?
    
    class func newInstance(map: Map) -> Mappable? {
        return LoginResponse()
    }
    
    func mapping(map: Map) {
        message <- map["message"]
        success <- map["success"]
        token <- map["token"]
        user <- map["user"]
        lists <- map["lists"]
    }
}