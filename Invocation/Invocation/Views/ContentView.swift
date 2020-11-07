//
//  ContentView.swift
//  Invocation
//
//  Created by Isaac Lyons on 10/29/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @AppStorage(Defaults.projectSort.rawValue) private var projectSort: Int = 0
    @AppStorage(Defaults.projectSortAscending.rawValue) private var projectSortAscending: Bool = true
    @AppStorage(Defaults.projectSortEmptyFirst.rawValue) private var projectSortEmptyFirst: Bool = false
    
    let checklistController = ChecklistController()
    
    @State private var projectsContainer: ObjectsContainer<Project>?
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            NavigationView {
                if let projectsContainer = projectsContainer {
                    ProjectsView(tab: $tab)
                        .environmentObject(projectsContainer)
                        .onChange(of: projectSort, perform: sort)
                        .onChange(of: projectSortAscending, perform: sort)
                        .onChange(of: projectSortEmptyFirst, perform: sort)
                }
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
        .onAppear {
            if projectsContainer == nil {
                initProjectsContainer()
            }
        }
    }
    
    func initProjectsContainer() {
        let projectsContainer = ObjectsContainer<Project>(method: projectSort, ascending: projectSortAscending, emptyFirst: projectSortEmptyFirst, context: moc)
        
        let comparisons: [ComparisonProtocol] = [
            Comparison<Project, Date>(makeComparison: { project -> Date? in
                project.invoked
            }),
            Comparison<Project, String>(makeComparison: { project -> String? in
                project.wrappedTitle.lowercased()
            }),
            Comparison<Project, Date>(makeComparison: { project -> Date? in
                project.lastCompletedTask?.completed
            })
        ]
        
        projectsContainer.comparisons.append(contentsOf: comparisons)
        projectsContainer.sort()
        
        self.projectsContainer = projectsContainer
    }
    
    func sort(_: Any) {
        projectsContainer?.sort(method: projectSort, ascending: projectSortAscending, emptyFirst: projectSortEmptyFirst)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
