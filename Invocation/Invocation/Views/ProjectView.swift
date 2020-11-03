//
//  ProjectView.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/3/20.
//

import SwiftUI
import CoreData

struct ProjectView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.editMode) private var editMode
    
    private var tasksFetchRequest: FetchRequest<Task>
    private var tasks: FetchedResults<Task> {
        tasksFetchRequest.wrappedValue
    }
    
    @ObservedObject var project: Project
    
    @State private var title: String
    
    init(project: Project) {
        self.project = project
        self.tasksFetchRequest = FetchRequest(
            fetchRequest: project.allTasksFetchRequest(),
            animation: .default)
        _title = .init(wrappedValue: project.wrappedTitle)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Checklist Title", text: $title, onCommit: {
                    project.title = title
                    PersistenceController.save(context: moc)
                })
                .autocapitalization(.words)
            }
            
            Section(header: Text("Tasks")) {
                ForEach(tasks) { task in
                    Text(task.wrappedName ??? "Task")
                }
            }
        }
        .navigationTitle(project.wrappedTitle ??? "Invocation")
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var project: Project {
        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        fetchRequest.fetchLimit = 1
        let context = PersistenceController.preview.container.viewContext
        return try! context.fetch(fetchRequest).first!
    }
    
    static var previews: some View {
        NavigationView {
            ProjectView(project: project)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
