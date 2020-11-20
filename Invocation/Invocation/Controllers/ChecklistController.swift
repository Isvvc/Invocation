//
//  ChecklistController.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import Foundation
import HorizontalReorder
import UserNotifications

class ChecklistController: ObservableObject {
    
    var dateFormatter: DateFormatter
    
    @Published var datePreview: String
    
    private(set) var advancedDateFormat: Bool
    private(set) var dateStyle: Int
    private(set) var dateTimeFormat: [Int]
    private(set) var dateFormat: [Int]
    private(set) var showYear: Bool
    private(set) var showWeekday: Bool
    private(set) var monthFormat: Int
    private(set) var dateSeparator: String
    
    init() {
        UserDefaults.standard.register(defaults: [
            Defaults.showYear.rawValue: true,
            Defaults.showWeekday.rawValue: true,
            Defaults.dateSeparator.rawValue: "/",
            Defaults.dateStyle.rawValue: 1
        ])
        
        advancedDateFormat = UserDefaults.standard.bool(forKey: Defaults.advancedDateFormat.rawValue)
        dateStyle = UserDefaults.standard.integer(forKey: Defaults.dateStyle.rawValue)
        showYear = UserDefaults.standard.bool(forKey: Defaults.showYear.rawValue)
        showWeekday = UserDefaults.standard.bool(forKey: Defaults.showWeekday.rawValue)
        monthFormat = UserDefaults.standard.integer(forKey: Defaults.monthFormat.rawValue)
        dateSeparator = UserDefaults.standard.string(forKey: Defaults.dateSeparator.rawValue) ?? "/"
        
        let dateTimeFormatCode = UserDefaults.standard.integer(forKey: Defaults.dateTimeOrder.rawValue)
        let dateFormatCode = UserDefaults.standard.integer(forKey: Defaults.dateOrder.rawValue)
        
        dateTimeFormat = HorizontalDragObject.decode(lehmerCode: dateTimeFormatCode, length: 3)
        dateFormat = HorizontalDragObject.decode(lehmerCode: dateFormatCode, length: 3)
        
        dateFormatter = DateFormatter()
        datePreview = ""
        setFormat()
    }
    
    //MARK: Date format
    
    func setFormat() {
        if !advancedDateFormat {
            let dateStyle = DateFormatter.Style(rawValue: UInt(self.dateStyle)) ?? .short
            dateFormatter.dateStyle = dateStyle
            dateFormatter.timeStyle = .short
            datePreview = dateFormatter.string(from: Date())
        } else {
            var dateFormatStrings: [String?] = dateFormat.map {_ in ""}
            for (index, position) in dateFormat.enumerated() {
                switch index {
                case 0:
                    dateFormatStrings[position] = String(repeating: "M", count: monthFormat + 1)
                case 1:
                    dateFormatStrings[position] = "dd"
                default:
                    dateFormatStrings[position] = showYear ? "yyyy" : nil
                }
            }
            
            // Add a comma before the year
            if monthFormat >= 2 {
                if dateFormatStrings.first == "yyyy" {
                    dateFormatStrings[0]?.append(",")
                }
            }
            
            var dateTimeFormatStrings: [String?] = dateTimeFormat.map {_ in ""}
            for (index, position) in dateTimeFormat.enumerated() {
                switch index {
                case 0:
                    dateTimeFormatStrings[position] = showWeekday ? "E" : nil
                case 1:
                    dateTimeFormatStrings[position] = dateFormatStrings.compactMap { $0 }.joined(separator: monthFormat < 2 ? "'\(dateSeparator)'" : " ")
                default:
                    dateTimeFormatStrings[position] = "HH:mm"
                }
            }
            
            // Add a comma after the weekday
            if let index = dateTimeFormatStrings.firstIndex(of: "E"),
               index < 2 {
                dateTimeFormatStrings[index]?.append(",")
            }
            
            dateFormatter.dateFormat = dateTimeFormatStrings.compactMap { $0 }.joined(separator: " ")
            datePreview = dateFormatter.string(from: Date())
        }
    }
    
    func setAdvancedFormat(_ advanced: Bool) {
        advancedDateFormat = advanced
        setFormat()
    }
    
    func setDateStyle(_ style: Int) {
        dateStyle = style
        setFormat()
    }
    
    func setDateFormat(_ permutation: [Int]) {
        dateFormat = permutation
        setFormat()
    }
    
    func setDateTimeFormat(_ permutation: [Int]) {
        dateTimeFormat = permutation
        setFormat()
    }
    
    func setShowYear(_ show: Bool) {
        showYear = show
        setFormat()
    }
    
    func setShowWeekday(_ show: Bool) {
        showWeekday = show
        setFormat()
    }
    
    func setDateSeparator(_ separator: String) {
        dateSeparator = separator
        setFormat()
    }
    
    func setMonthFormat(_ format: Int) {
        monthFormat = format
        setFormat()
    }
    
    //MARK: Notifications
    
    func createNotifications(for project: Project) {
        guard let tasks = project.tasks as? Set<Task>  else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            guard granted else {
                if let error = error {
                    NSLog("\(error)")
                }
                return
            }
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.removeAllPendingNotificationRequests()
            tasks.compactMap { $0.makeNotification() }.forEach { notificationCenter.add($0) }
        }
    }
    
    //MARK: Misc
    
    /// Sets a URL's protocol to HTTPS.
    ///
    /// If the URL is already using HTTPS, it returns the same URL.
    /// If the URL is using HTTP, it converts it to HTTPS.
    /// If the URL is using neither, it prefixes it with `https://`.
    /// - Parameter url: A String of the URL to set the protocol of.
    /// - Returns: the URL with an `https://` prefix.
    func https(_ url: String) -> String {
        if url.hasPrefix("https://") {
            return url
        }
        
        if url.hasPrefix("http://") {
            var newURL = url
            if let index = newURL.firstIndex(of: ":") {
                newURL.insert("s", at: index)
                return newURL
            }
        }
        
        return "https://" + url
    }
    
}
