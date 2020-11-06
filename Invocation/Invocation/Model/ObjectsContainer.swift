//
//  ObjectsContainer.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/5/20.
//

import SwiftUI
import CoreData

protocol ComparisonProtocol {
    func sort<FunctionType: NSManagedObject>(_ objects: [FunctionType], ascending: Bool) -> [FunctionType]
}

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
            guard let object1Comparison = value(for: object1) else { return false }
            guard let object2Comparison = value(for: object2) else { return true }
            if ascending {
                return object1Comparison < object2Comparison
            } else {
                return object1Comparison > object2Comparison
            }
        } as? [FunctionType] ?? []
    }
}

class ObjectsContainer<T: NSManagedObject>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    var frc: NSFetchedResultsController<T>
    
    @Published var sortedObjects: [T] = []
    
    var method: Int
    var ascending: Bool
    
    var comparisons: [ComparisonProtocol] = []
    
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
    
    func sort() {
        guard let items = frc.fetchedObjects else { return }
        
        let index: Int
        if method < comparisons.count {
            index = method
        } else if comparisons.count > 0 {
            index = 0
        } else {
            return
        }
        
        let comparison = comparisons[index]
        
        sortedObjects = comparison.sort(items, ascending: ascending)
    }
    
    func sort(method: Int, ascending: Bool) {
        self.method = method
        self.ascending = ascending
        sort()
    }
    
    /*
    func sort() {
        guard T.self == Project.self else { return }
        
        // true if 1 is before 2
        let sortFunc: (Project, Project) -> Bool
        
        // 0: Invocation Date
        // 1: Name
        // 2: Last completed task
        switch method {
        case 2:
            var lastCompleted: [Project: Date?] = [:]
            frc.fetchedObjects?.forEach { lastCompleted[$0] = $0.lastCompletedTask?.completed }
            sortFunc = { project1, project2 in
                // Dates come out as double optionals
                guard case let project1Date?? = lastCompleted[project1] else { return false }
                guard case let project2Date?? = lastCompleted[project2] else { return true }
                return project1Date > project2Date
            }
        default:
            sortFunc = { project1, project2 in
                project1.wrappedTitle > project2.wrappedTitle
            }
        }
        
        sortedProjects = fetchedResults.sorted(by: sortFunc)
    }*/
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sort()
    }
}
