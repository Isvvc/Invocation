//
//  ContentView.swift
//  Invocation
//
//  Created by Isaac Lyons on 10/29/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    let checklistController = ChecklistController()

    var body: some View {
        TabView {
            NavigationView {
                ChecklistsView()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Checklists")
            }
        }
        .environmentObject(checklistController)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
