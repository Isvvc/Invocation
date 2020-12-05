//
//  ContentView.swift
//  Invocation
//
//  Created by Isaac Lyons on 10/29/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    static let newProjectType = "vc.isv.Invocation.new-project"
    
    @Environment(\.managedObjectContext) private var moc
    
    @AppStorage(Defaults.projectSort.rawValue) private var projectSort: Int = 0
    @AppStorage(Defaults.projectSortAscending.rawValue) private var projectSortAscending: Bool = true
    @AppStorage(Defaults.projectSortEmptyFirst.rawValue) private var projectSortEmptyFirst: Bool = false
    
    let checklistController = ChecklistController()
    
    @State private var projectsContainer: ObjectsContainer<Project>?
    @State private var newProject: Project?
    @SceneStorage("selectedTab") private var tab = 0

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
                ChecklistsView(newProject: $newProject)
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
        .sheet(item: $newProject) { newProject in
            NavigationView {
                ProjectView(project: newProject)
            }
            .environment(\.managedObjectContext, moc)
            .environmentObject(checklistController)
        }
        .userActivity(ContentView.newProjectType, element: newProject) { newProject, activity in
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            activity.isEligibleForHandoff = false

            activity.title = "Invoke \(newProject.checklist?.title ?? "Checklist")"
            activity.userInfo = ["id": newProject.checklist?.id?.uuidString as Any]

            print("Advertising Invoke \(newProject.checklist?.title ?? "Checklist")")
        }
        .onContinueUserActivity(ContentView.newProjectType) { userActivity in
            guard newProject == nil,
                  let checklistIDString = userActivity.userInfo?["id"] as? String,
                  let checklistID = UUID(uuidString: checklistIDString) else { return }
            newProject = checklistController.invoke(checklistID: checklistID, context: moc)
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
