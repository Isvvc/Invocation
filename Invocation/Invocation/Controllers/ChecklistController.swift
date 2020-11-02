//
//  ChecklistController.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import Foundation

class ChecklistController: ObservableObject {
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
