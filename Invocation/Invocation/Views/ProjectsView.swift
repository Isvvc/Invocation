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
            }
        }
        .listStyle(GroupedListStyle())
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
    @State private var completed: [Task: Bool] = [:]
    
    init(project: Project) {
        self.project = project
        tasksFetchRequest = FetchRequest(
            fetchRequest: project.tasksFetchRequest(),
            animation: .default)
        
        (project.tasks as! Set<Task>).forEach { completed[$0] = false }
    }
    
    private var header: some View {
        Button {
            withAnimation {
                expanded.toggle()
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    Text(project.wrappedTitle ??? "Project")
                        .font(.title)
                        .foregroundColor(.primary)
                    Text("\(project.tasks?.count ?? 0) Tasks")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Spacer()
                Image(systemName: "chevron.forward")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .rotationEffect(expanded ? .degrees(90) : .zero)
            }
        }
        .textCase(.none)
    }
    
    var body: some View {
        Section(header: header) {
            if expanded {
                ForEach(tasks) { task in
                    Button {
                        task.toggle()
                    } label: {
                        HStack {
                            if project.showComplete {
                                Image(systemName: completed[task] == true ? "checkmark.square" : "square")
                                    .imageScale(.large)
                                if task.completed != nil {
                                    Text("a")
                                }
                            }
                            Text(task.wrappedName ??? "Task")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
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
