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
    
    let checklistController = ChecklistController()
    
    @State private var projectsContainer: ObjectsContainer<Project>?
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            NavigationView {
                if let projectsContainer = projectsContainer {
                    ProjectsView(projectsContainer: projectsContainer, tab: $tab)
                        .onChange(of: projectSort) { projectSort in
                            projectsContainer.sort(method: projectSort, ascending: projectSortAscending)
                        }
                        .onChange(of: projectSortAscending) { projectSortAscending in
                            projectsContainer.sort(method: projectSort, ascending: projectSortAscending)
                        }
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
        let projectsContainer = ObjectsContainer<Project>(method: projectSort, ascending: projectSortAscending, context: moc)
        
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
