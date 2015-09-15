//
//  User.swift
//  
//
//  Created by Edgar Cardoso on 9/15/15.
//
//
import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var email: String
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var lists: NSOrderedSet

    class func userFromJSON(json: NSDictionary, andContext context: NSManagedObjectContext) -> User {
        let userEntity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
        let user = User(entity: userEntity!, insertIntoManagedObjectContext: context)
        
        user.email = json["email"] as! String
        user.id = json["id"] as! String
        user.name = json["name"] as! String
        
        return user
    }
}
