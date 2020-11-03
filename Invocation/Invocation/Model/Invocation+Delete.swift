//
//  Invocation+Delete.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/3/20.
//

import CoreData

extension NSManagedObject {
    func deleteChildren(at key: String, context: NSManagedObjectContext) {
        (mutableSetValue(forKey: key) as? Set<NSManagedObject>)?.forEach(context.delete)
    }
}

extension Checklist {
    func deleteChildren(context: NSManagedObjectContext) {
        deleteChildren(at: "items", context: context)
        if let projects = projects as? Set<Project> {
            projects.forEach { $0.deleteChildrenAndSelf(context: context) }
        }
    }
    
    func deleteChildrenAndSelf(context: NSManagedObjectContext) {
        deleteChildren(context: context)
        context.delete(self)
    }
}

extension Project {
    func deleteChildren(context: NSManagedObjectContext) {
        deleteChildren(at: "tasks", context: context)
    }
    
    func deleteChildrenAndSelf(context: NSManagedObjectContext) {
        deleteChildren(at: "tasks", context: context)
        context.delete(self)
    }
}
