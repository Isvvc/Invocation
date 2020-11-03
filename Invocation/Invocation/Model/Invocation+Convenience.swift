//
//  Invocation+Convenience.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import CoreData

extension Project {
    @discardableResult
    convenience init(checklist: Checklist, context: NSManagedObjectContext) {
        self.init(context: context)
        self.checklist = checklist
        self.showComplete = checklist.showComplete
        self.showOne = checklist.showOne
        
        guard let items = checklist.items as? Set<Item> else { return }
        let tasks = mutableSetValue(forKey: "tasks")
        tasks.addObjects(from: items.map { Task(item: $0, context: context) })
    }
}

extension Task {
    @discardableResult
    convenience init(item: Item, context: NSManagedObjectContext) {
        self.init(context: context)
        self.item = item
        self.index = item.index
    }
    
    func toggle() {
        if completed == nil {
            complete()
        } else {
            completed = nil
        }
    }
    
    func complete() {
        completed = Date()
    }
}
