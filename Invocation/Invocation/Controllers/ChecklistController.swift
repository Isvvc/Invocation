//
//  ChecklistController.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import Foundation

class ChecklistController: ObservableObject {
    
    var dateFormatter: DateFormatter
    
    init() {
        var dateStyle = UserDefaults.standard.integer(forKey: Defaults.dateStyle.rawValue)
        var timeStyle = UserDefaults.standard.integer(forKey: Defaults.timeStyle.rawValue)
        
        // Style 0 is none (and the default value when installing the app).
        // We want there to be a date and time, so set them to short by default.
        if dateStyle == 0 {
            dateStyle = 1
            UserDefaults.standard.set(1, forKey: Defaults.dateStyle.rawValue)
        }
        if timeStyle == 0 {
            timeStyle = 1
            UserDefaults.standard.set(1, forKey: Defaults.timeStyle.rawValue)
        }
        
        dateFormatter = DateFormatter()
        setDateFormat(dateStyleInt: dateStyle, timeStyleInt: timeStyle)
    }
    
    func setDateFormat(dateStyleInt: Int, timeStyleInt: Int) {
        let dateStyle = DateFormatter.Style(rawValue: UInt(dateStyleInt)) ?? .short
        let timeStyle = DateFormatter.Style(rawValue: UInt(timeStyleInt)) ?? .short
        
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
    }
    
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
