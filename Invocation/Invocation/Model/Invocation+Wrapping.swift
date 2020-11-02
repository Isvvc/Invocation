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
