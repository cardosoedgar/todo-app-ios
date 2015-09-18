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
        NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
    }
    
    func getToken() -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey("token") as? String
    }
    
    func getUser(context: NSManagedObjectContext) -> User? {
        let userFetch = NSFetchRequest(entityName: "User")
        
        do {
            let result = try context.executeFetchRequest(userFetch) as? [User]
            return result!.first
        } catch let error as NSError {
            print("fetch failed: \(error)")
            return User()
        }
    }
    
    func deleteToken() {
        setToken(nil)
    }
    
    func getHeader() -> [String: String] {
        return ["x-access-token" : getToken()!]
    }
}