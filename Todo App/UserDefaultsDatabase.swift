//
//  Database.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//
import CoreData
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
    
    func getUser(context: NSManagedObjectContext) -> User {
        let userFetch = NSFetchRequest(entityName: "User")
        var error: NSError?
        
        let result = context.executeFetchRequest(userFetch, error: &error) as! [User]?
        
        if let users = result {
            return users.first!
        } else {
            return User()
        }
    }
}