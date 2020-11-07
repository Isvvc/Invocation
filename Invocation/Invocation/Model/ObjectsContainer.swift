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
    func sort<FunctionType: NSManagedObject>(_ objects: [FunctionType], ascending: Bool, emptyFirst: Bool) -> [FunctionType]
    func insert<FunctionType: NSManagedObject>(_ object: FunctionType, into sortedObjects: inout [FunctionType], ascending: Bool, emptyFirst: Bool)
    func move<FunctionType: NSManagedObject>(_ object: FunctionType, in sortedObjects: inout [FunctionType], ascending: Bool, emptyFirst: Bool)
}

//MARK: Comparison

struct Comparison<T: NSManagedObject, C: Comparable>: ComparisonProtocol {
    var makeComparison: (T) -> C?
    
    func sort<FunctionType: NSManagedObject>(_ objects: [FunctionType], ascending: Bool, emptyFirst: Bool) -> [FunctionType] {
        //TODO: Make these objects an inout like insert and move
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
            guard let object1Comparison = value(for: object1) else { return emptyFirst }
            guard let object2Comparison = value(for: object2) else { return !emptyFirst }
            
            return ascending == (object1Comparison < object2Comparison)
        } as? [FunctionType] ?? []
    }
    
    func insert<FunctionType: NSManagedObject>(_ object: FunctionType, into objects: inout [FunctionType], ascending: Bool, emptyFirst: Bool) {
        guard let sortedObjects = objects as? [T],
              let objectToInsert = object as? T else { return }
        
        if let index = indexToInsert(objectToInsert, into: sortedObjects, ascending: ascending, emptyFirst: emptyFirst) {
            objects.insert(object, at: index)
        } else {
            if emptyFirst {
                objects.insert(object, at: 0)
            } else {
                objects.append(object)
            }
        }
    }
    
    func move<FunctionType: NSManagedObject>(_ object: FunctionType, in objects: inout [FunctionType], ascending: Bool, emptyFirst: Bool) {
        guard let originalIndex = objects.firstIndex(of: object),
              let objectToMove = object as? T,
              var sortedObjects = objects as? [T] else { return }
        sortedObjects.remove(at: originalIndex)
        
        if let index = indexToInsert(objectToMove, into: sortedObjects, ascending: ascending, emptyFirst: emptyFirst) {
            if index != originalIndex {
                objects.remove(at: originalIndex)
                objects.insert(object, at: index)
            }
        } else {
            objects.remove(at: originalIndex)
            if emptyFirst {
                objects.insert(object, at: 0)
            } else {
                objects.append(object)
            }
        }
    }
    
    private func indexToInsert(_ object: T, into objects: [T], ascending: Bool, emptyFirst: Bool) -> Int? {
        guard let comparison = makeComparison(object) else { return nil }
        // Find the first object that belongs after the given object
        return objects.firstIndex { object -> Bool in
            guard let existingComparison = makeComparison(object) else { return emptyFirst }
            return ascending == (comparison < existingComparison)
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
    var emptyFirst: Bool
    
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
    
    init(method: Int, ascending: Bool, emptyFirst: Bool, context: NSManagedObjectContext) {
        self.method = method
        self.ascending = ascending
        self.emptyFirst = emptyFirst
        
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
        
        sortedObjects = comparison.sort(items, ascending: ascending, emptyFirst: emptyFirst)
    }
    
    func sort(method: Int, ascending: Bool, emptyFirst: Bool) {
        self.method = method
        self.ascending = ascending
        self.emptyFirst = emptyFirst
        sort()
    }
    
    func update(object: T) {
        currentComparison?.move(object, in: &sortedObjects, ascending: ascending, emptyFirst: emptyFirst)
    }
    
    //MARK: Fetched Results Controller Delegate
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        guard let object = anObject as? T else { return }
        switch type {
        case .insert:
            currentComparison?.insert(object, into: &sortedObjects, ascending: ascending, emptyFirst: emptyFirst)
        case .delete:
            sortedObjects.removeAll(where: { $0 == object })
        default:
            break
        }
    }
}
