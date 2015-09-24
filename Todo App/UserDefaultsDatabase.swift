//
//  Database.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//
import CoreData
import Foundation

class UserDefaultsDatabase
{
    func setToken(token: String?) {
        NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
    }
    
    func getToken() -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey("token") as? String
    }
    
    func toggleAutoBackup(isOn: Bool) {
        NSUserDefaults.standardUserDefaults().setValue(isOn, forKey: "autobackup")
    }
    
    func isAutoBackupOn() -> Bool {
        return NSUserDefaults.standardUserDefaults().valueForKey("autobackup") as! Bool
    }
    
    func isFirstTime() -> Bool {
        if (NSUserDefaults.standardUserDefaults().valueForKey("firsttime") as? Bool == nil) {
            return true
        }
        
        return false
    }
    
    func setFirstTime() {
        NSUserDefaults.standardUserDefaults().setValue(false, forKey: "firsttime")
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
    
    func isUserLoggedIn() -> Bool {
        if getToken() == "not signed" {
            return false
        }
        
        return true
    }
}