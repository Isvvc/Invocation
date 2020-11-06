//
//  Invocation+Wrapping.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import Foundation

extension Checklist {
    var wrappedTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
}

extension Item {
    var wrappedName: String {
        get { name ?? "" }
        set {
            objectWillChange.send()
            name = newValue
        }
    }
    
    var wrappedNotes: String {
        get { notes ?? "" }
        set { notes = newValue }
    }
}

extension Project {
    var wrappedTitle: String {
        get { title ?? checklist?.title ?? "" }
        set { title = newValue }
    }
    
    var lastCompletedTask: Task? {
        // This could be done with the max(by:) function,
        // but that's always confusing to use.
        var lastTask: Task?
        for task in tasks as? Set<Task> ?? [] {
            guard let date = task.completed else { continue }
            if let lastTaskDate = lastTask?.completed {
                if date > lastTaskDate {
                    lastTask = task
                }
            } else {
                lastTask = task
            }
        }
        return lastTask
    }
}

extension Task {
    var wrappedName: String {
        get { name ?? item?.name ?? "" }
        set { name = newValue }
    }
}

infix operator ???: NilCoalescingPrecedence
extension String {
    static func ??? (num: String, power: String) -> String {
        if num.isEmpty {
            return power
        }
        return num
    }
}
