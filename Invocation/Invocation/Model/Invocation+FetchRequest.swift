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
}
