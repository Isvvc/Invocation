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
    
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            NavigationView {
                ProjectsView(tab: $tab)
            }
            .tabItem {
                Image(systemName: "text.badge.checkmark")
                Text("Invocations")
            }
            .tag(0)
            
            NavigationView {
                ChecklistsView()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Checklists")
            }
            .tag(1)
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(2)
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
