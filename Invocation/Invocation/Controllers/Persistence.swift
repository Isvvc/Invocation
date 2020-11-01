//
//  Persistence.swift
//  Invocation
//
//  Created by Isaac Lyons on 10/29/20.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newChecklist = Checklist(context: viewContext)
            newChecklist.title = String(UUID().uuidString.prefix(8))
            
            for i in 0..<Int16.random(in: 3..<10) {
                let newItem = Item(context: viewContext)
                newItem.name = String(UUID().uuidString.prefix(8))
                newItem.checklist = newChecklist
                newItem.index = i
            }
        }
        result.save()
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Invocation")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else if let description = container.persistentStoreDescriptions.first {
            description.setOption(true as NSObject, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(processUpdate), name: .NSPersistentStoreRemoteChange, object: self.container)
    }
    
    //MARK: Saving
    
    func save() {
        PersistenceController.save(context: container.viewContext)
    }
    
    static func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    //MARK: Merging changes
    
    lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    @objc
    private func processUpdate(notification: Notification) {
        operationQueue.addOperation {
            guard let container = notification.object as? NSPersistentCloudKitContainer else { return }
            let context = container.newBackgroundContext()
            
            context.performAndWait {
                do {
                    // Ideally this should only run on Checklists that have been modified,
                    // not every single checklist like we're doing here.
                    let checklistsFetchRequest: NSFetchRequest<Checklist> = Checklist.fetchRequest()
                    let checklists = try context.fetch(checklistsFetchRequest)
                    
                    // Update the indices of each Checklist's Items
                    for checklist in checklists {
                        try checklist.updateIndices(context: context)
                    }
                    
                    // Only save if there are changes so we don't get in infinite loop
                    // of saving and responding to that save.
                    if context.hasChanges {
                        try context.save()
                    }
                } catch {
                    let nsError = error as NSError
                    NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
}
