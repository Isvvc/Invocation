//
//  Set+Convenience.swift
//  Invocation
//
//  Created by Isaac Lyons on 12/3/20.
//

import Foundation

extension Set {
    mutating func toggle(_ member: Element) {
        if contains(member) {
            remove(member)
        } else {
            insert(member)
        }
    }
}
