//
//  Database.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import Foundation

class UserDefaultsDatabase: DatabaseProtocol
{
    func setToken(token: String?) {
        if token != nil {
            NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
        }
    }
    
    func getToken() -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey("token") as? String
    }
}