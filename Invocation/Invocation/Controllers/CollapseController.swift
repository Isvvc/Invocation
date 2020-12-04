//
//  CollapseController.swift
//  Invocation
//
//  Created by Isaac Lyons on 12/3/20.
//

import SwiftUI

class CollapseController<T: Hashable>: ObservableObject {
    @Published var collapsed: Set<T> = []
    @Published var collapseQueue: Set<T> = []
    private var collapsing = false
    
    @discardableResult
    func toggle(_ object: T) -> Bool {
        if !collapsing {
            startCollapsing()
            withAnimation {
                collapsed.toggle(object)
            }
        } else {
            collapseQueue.insert(object)
        }
        return collapsed.contains(object) ? !collapseQueue.contains(object) : collapseQueue.contains(object)
    }
    
    private func startCollapsing() {
        collapsing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            self.collapsing = false
            if !self.collapseQueue.isEmpty {
                self.startCollapsing()
                withAnimation {
                    self.collapseQueue.forEach { self.collapsed.toggle($0) }
                }
                self.collapseQueue.removeAll()
            }
        }
    }
}
