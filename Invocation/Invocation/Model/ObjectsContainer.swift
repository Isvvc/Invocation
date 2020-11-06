//
//  ObjectsContainer.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/5/20.
//

import SwiftUI
import CoreData

//MARK: Comparison Protocol

protocol ComparisonProtocol {
    func sort<FunctionType: NSManagedObject>(_ objects: [FunctionType], ascending: Bool) -> [FunctionType]
    func insert<FunctionType: NSManagedObject>(_ object: FunctionType, into sortedObjects: inout [FunctionType], ascending: Bool)
}

//MARK: Comparison

struct Comparison<T: NSManagedObject, C: Comparable>: ComparisonProtocol {
    var makeComparison: (T) -> C?
    
    func sort<FunctionType: NSManagedObject>(_ objects: [FunctionType], ascending: Bool) -> [FunctionType] {
        guard let objects = objects as? [T] else { return [] }
        var cache: [T: C?] = [:]
        
        func value(for object: T) -> C? {
            if let value = cache[object] {
                return value
            } else {
                let value: C? = makeComparison(object)
                cache[object] = value
                return value
            }
        }
        
        return objects.sorted { object1, object2 -> Bool in
            // Put nil values at the end.
            //TODO: Make this configurable
            guard let object1Comparison = value(for: object1) else { return false }
            guard let object2Comparison = value(for: object2) else { return true }
            
            return ascending == (object1Comparison < object2Comparison)
        } as? [FunctionType] ?? []
    }
    
    func insert<FunctionType: NSManagedObject>(_ object: FunctionType, into objects: inout [FunctionType], ascending: Bool) {
        guard let sortedObjects = objects as? [T],
              let objectToInsert = object as? T else { return }
        
        if let comparison = makeComparison(objectToInsert),
           // Find the first object that belongs after the given object
           let index = sortedObjects.firstIndex(where: { object -> Bool in
            guard let existingComparison = makeComparison(object) else { return false }
            return ascending == (comparison < existingComparison)
           }) {
            objects.insert(object, at: index)
        } else {
            objects.append(object)
        }
    }
}

//MARK: Objects Container

class ObjectsContainer<T: NSManagedObject>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    //MARK: Properties
    
    var frc: NSFetchedResultsController<T>
    
    @Published var sortedObjects: [T] = []
    
    var method: Int
    var ascending: Bool
    
    var comparisons: [ComparisonProtocol] = []
    var currentComparison: ComparisonProtocol? {
        let index: Int
        if method < comparisons.count {
            index = method
        } else if comparisons.count > 0 {
            index = 0
        } else {
            return nil
        }
        
        return comparisons[index]
    }
    
    init(method: Int, ascending: Bool, context: NSManagedObjectContext) {
        self.method = method
        self.ascending = ascending
        
        let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        try? frc.performFetch()
        
        super.init()
        frc.delegate = self
    }
    
    //MARK: Methods
    
    func sort() {
        guard let items = frc.fetchedObjects,
              let comparison = currentComparison else { return }
        
        sortedObjects = comparison.sort(items, ascending: ascending)
    }
    
    func sort(method: Int, ascending: Bool) {
        self.method = method
        self.ascending = ascending
        sort()
    }
    
    //MARK: Fetched Results Controller Delegate
    
    /*
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sort()
    }
     */
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let object = anObject as? T else { break }
            currentComparison?.insert(object, into: &sortedObjects, ascending: ascending)
        default:
            break
        }
    }
}
