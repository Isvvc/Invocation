//
//  View+Keyboard.swift
//  Invocation
//
//  Created by Isaac Lyons on 12/1/20.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
