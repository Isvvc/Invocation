//
//  InvocationApp.swift
//  Invocation
//
//  Created by Isaac Lyons on 10/29/20.
//

import SwiftUI

@main
struct InvocationApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
