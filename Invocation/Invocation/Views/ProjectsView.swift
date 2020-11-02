//
//  ProjectsView.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import SwiftUI

struct ProjectsView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)],
        animation: .default)
    private var projects: FetchedResults<Project>
    
    var body: some View {
        List {
            ForEach(projects) { project in
                ProjectSection(project: project)
//                    .environment(\.managedObjectContext, moc)
            }
        }
        .navigationTitle("Invocations")
    }
}

fileprivate struct ProjectSection: View {
    
    private var tasksFetchRequest: FetchRequest<Task>
    private var tasks: FetchedResults<Task> {
        tasksFetchRequest.wrappedValue
    }
    
    @ObservedObject var project: Project
    
    @State private var expanded = true
    
    init(project: Project) {
        self.project = project
        tasksFetchRequest = FetchRequest(
            fetchRequest: project.tasksFetchRequest(),
            animation: .default)
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $expanded) {
            ForEach(tasks) { task in
                HStack {
                    Text(task.wrappedName ??? "Task")
                    if task.completed != nil {
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        } label: {
            VStack(alignment: .leading) {
                Text(project.wrappedTitle ??? "Project")
                    .font(.title)
                Text("\(project.tasks?.count ?? 0) tasks")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectsView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
