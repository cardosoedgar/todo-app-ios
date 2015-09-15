//
//  Task.swift
//  
//
//  Created by Edgar Cardoso on 9/15/15.
//
//

import Foundation
import CoreData

class Task: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var list: List

    class func taskFromJSON(json: NSDictionary, andContext context: NSManagedObjectContext) -> Task {
        let taskEntity = NSEntityDescription.entityForName("Task", inManagedObjectContext: context)
        let task = Task(entity: taskEntity!, insertIntoManagedObjectContext: context)
        
        task.id = json["id"] as! NSNumber
        task.name = json["name"] as! String
        
        return task
    }
}
