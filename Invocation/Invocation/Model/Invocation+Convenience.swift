//
//  Invocation+Convenience.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import CoreData
import SwiftDate

extension Project {
    @discardableResult
    convenience init(checklist: Checklist, context: NSManagedObjectContext) {
        self.init(context: context)
        self.checklist = checklist
        self.showComplete = checklist.showComplete
        self.showOne = checklist.showOne
        self.invoked = Date()
        
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
        if item.due {
            self.due = item.nextDueDate
        }
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
    
    var dueDateIsUnchanged: Bool {
        if due == nil,
           item?.due == false {
            return true
        }
        
        guard let invocation = project?.invoked else { return false }
        let dueDate = due?.dateRoundedAt(at: .toFloorMins(1))
        let itemDueDate = item?.dueDate(after: invocation).dateRoundedAt(at: .toFloorMins(1))
        return dueDate == itemDueDate
    }
    
    func resetDueDate() {
        guard let invocation = project?.invoked else { return }
        due = item?.dueDate(after: invocation)
    }
}

extension Item {
    var nextDueDate: Date {
        dueDate(after: Date())
    }
    
    func dueDate(after date: Date) -> Date {
        let offsetDate = DateInRegion(date, region: .current)
            .dateByAdding(Int(dateOffset), .day)
        let dateComponents = offsetDate.dateComponents
        
        let timeComponents: DateComponents
        
        if let time = time {
            timeComponents = DateInRegion(time, region: .current).dateComponents
        } else {
            timeComponents = dateComponents
        }
        
        var dateAndTime = DateInRegion(year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!,
                                       hour: timeComponents.hour!, minute: timeComponents.minute!, region: .current)
        
        if time == nil {
            dateAndTime.addTimeInterval(timeInterval)
        }
        
        // Ensure the next due date isn't in the past
        if dateAndTime.date < date {
            dateAndTime = dateAndTime + 1.days
        }
        
        if let weekday = WeekDay(rawValue: Int(weekday)),
           weekday.rawValue != dateAndTime.weekday {
            return dateAndTime.nextWeekday(weekday).date
        }
        
        return dateAndTime.date
    }
}
