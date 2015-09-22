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

    @NSManaged var id: NSNumber?
    @NSManaged var name: String
    @NSManaged var done: Bool
    @NSManaged var list: List

    class func taskFromJSON(json: NSDictionary, andContext context: NSManagedObjectContext) -> Task {
        let taskEntity = NSEntityDescription.entityForName("Task", inManagedObjectContext: context)
        let task = Task(entity: taskEntity!, insertIntoManagedObjectContext: context)
        
        task.id = json["id"] as? NSNumber
        task.name = json["name"] as! String
        
        if let done = json["done"] as? Bool {
            task.done = done
        } else {
            task.done = false
        }
        
        return task
    }
    
    func updateId(json: NSDictionary) {
        id = json["id"] as? NSNumber
    }
    
    func markAsDone() {
        done = true
    }
    
    func markUndone() {
        done = false
    }
}
