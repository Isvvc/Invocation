//
//  Invocation+Wrapping.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import Foundation
import SwiftDate

//MARK: Checklist

extension Checklist {
    var wrappedTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
}

//MARK: Item

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
    
    var wrappedTime: Date {
        get { time ?? Date() + 10.minutes }
        set { time = newValue }
    }
}

//MARK: Project

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

//MARK: Task

extension Task {
    var wrappedName: String {
        get { name ?? item?.name ?? "" }
        set {
            if newValue == item?.name {
                name = nil
            }
            name = newValue
        }
    }
    
    var wrappedNotes: String {
        get { notes ?? item?.notes ?? "" }
        set {
            if newValue == item?.notes {
                notes = nil
            }
            notes = newValue
        }
    }
    
    var wrappedOptionalLink: URL? {
        get { link ?? item?.link }
        set {
            if newValue == item?.link {
                link = nil
            }
            link = newValue
        }
    }
    
    var wrappedDueDate: Date {
        get { due ?? Date() + 10.minutes }
        set { due = newValue }
    }
}

//MARK: Operators

infix operator ???: NilCoalescingPrecedence
extension String {
    static func ??? (num: String, power: String) -> String {
        if num.isEmpty {
            return power
        }
        return num
    }
}
