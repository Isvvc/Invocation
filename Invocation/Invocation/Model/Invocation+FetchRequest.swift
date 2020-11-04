//
//  Invocation+FetchRequest.swift
//  Invocation
//
//  Created by Isaac Lyons on 10/31/20.
//

import CoreData

extension Checklist {
    func itemsFetchRequest() -> NSFetchRequest<Item> {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "checklist == %@", self)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.index, ascending: true)]
        return fetchRequest
    }
    
    func updateIndices(context: NSManagedObjectContext) throws {
        let items = try context.fetch(itemsFetchRequest())
        updateIndices(items: items)
    }
    
    func updateIndices<T: Sequence>(items: T) where T.Element == Item {
        for (index, item) in items.enumerated() {
            let index = Int16(index)
            if item.index != index {
                item.index = index
            }
        }
    }
}

extension Project {
    func tasksFetchRequest() -> NSFetchRequest<Task> {
        tasksFetchRequest(showComplete: showOne ? false : showComplete)
    }
    
    func allTasksFetchRequest() -> NSFetchRequest<Task> {
        tasksFetchRequest(showComplete: true)
    }
    
    func tasksFetchRequest(showComplete: Bool) -> NSFetchRequest<Task> {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        var predicates = [NSPredicate(format: "project == %@", self)]
        
        if !showComplete {
            predicates.append(NSPredicate(format: "completed == nil"))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.index, ascending: true)]
        return fetchRequest
    }
    
    func updateIndices(context: NSManagedObjectContext) throws {
        let items = try context.fetch(tasksFetchRequest())
        updateIndices(items: items)
    }
    
    func updateIndices<T: Sequence>(items: T) where T.Element == Task {
        for (index, item) in items.enumerated() {
            let index = Int16(index)
            if item.index != index {
                item.index = index
            }
        }
    }
}
