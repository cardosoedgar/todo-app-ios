//
//  List.swift
//  
//
//  Created by Edgar Cardoso on 9/15/15.
//
//
import Foundation
import CoreData

class List: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var user: User
    @NSManaged var tasks: NSOrderedSet

    class func listFromJSON(json: NSDictionary, andContext context: NSManagedObjectContext) -> List{
        let listEntity = NSEntityDescription.entityForName("List", inManagedObjectContext: context)
        let list = List(entity: listEntity!, insertIntoManagedObjectContext: context)
        
        list.id = json["id"] as! NSNumber
        list.name = json["name"] as! String
        
        return list
    }
}
