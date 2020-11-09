//
//  Invocation+Wrapping.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import Foundation
import SwiftDate

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
    
    var wrappedTime: Date {
        get { time ?? Date() + 10.minutes }
        set { time = newValue }
    }
    
    var nextDueDate: Date {
        let now = Date()
        
        let offsetDate = DateInRegion(now, region: .current)
            .dateByAdding(Int(dateOffset), .day)
        let dateComponents = offsetDate.dateComponents
        let timeComponents = DateInRegion(wrappedTime, region: .current).dateComponents
        
        var dateAndTime = DateInRegion(year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!,
                                       hour: timeComponents.hour!, minute: timeComponents.minute!, region: .current)
        
        // Ensure the next due date isn't in the past
        if dateAndTime.date < Date() {
            dateAndTime = dateAndTime + 1.days
        }
        
        if let weekday = WeekDay(rawValue: Int(weekday)),
           weekday.rawValue != dateAndTime.weekday {
            return dateAndTime.nextWeekday(weekday).date
        }
        
        return dateAndTime.date
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
