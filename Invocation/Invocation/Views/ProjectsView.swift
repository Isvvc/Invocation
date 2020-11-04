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
    
    @Binding var tab: Int
    
    var body: some View {
        Group {
            if projects.count == 0 {
                VStack {
                    Text("Invocations of checklists appear here.")
                        .foregroundColor(.secondary)
                        .padding()
                    Button("Go to checklistst tab") {
                        tab = 1
                    }
                    .padding(.bottom)
                }
            } else {
                List {
                    ForEach(projects) { project in
                        ProjectSection(project: project)
                    }
                }
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
    
    init(project: Project) {
        self.project = project
        tasksFetchRequest = FetchRequest(
            fetchRequest: project.tasksFetchRequest(),
            animation: .default)
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
    
    private var footer: some View {
        NavigationLink(destination: ProjectView(project: project)) {
            HStack {
                Spacer()
                Text("Details")
                Image(systemName: "chevron.forward")
            }
        }
    }
    
    var body: some View {
        Section(header: header, footer: footer) {
            if expanded {
                ForEach(tasks) { task in
                    TaskCell(task: task, showComplete: project.showComplete)
                }
            }
        }
    }
}

fileprivate struct TaskCell: View {
    
    @ObservedObject var task: Task
    
    var showComplete: Bool
    
    @State private var completed = false
    @State private var work: DispatchWorkItem?
    
    var body: some View {
        Button(action: completeTask) {
            HStack {
                if showComplete {
                    Image(systemName: task.completed != nil ? "checkmark.square" : "square")
                        .imageScale(.large)
                }
                Text(task.wrappedName ??? "Task")
                    .foregroundColor(.primary)
            }
        }
        .overlay(
            Rectangle()
                .frame(maxWidth: completed ? .infinity : 0, maxHeight: 1)
                .animation(.easeIn(duration: 0.125))
        )
    }
    
    func completeTask() {
        if showComplete {
            task.toggle()
        } else {
            if completed {
                work?.cancel()
            } else {
                // Complete the task in 1 second to give time for
                // the animation to play and for the user to cancel.
                let work = DispatchWorkItem {
                    task.complete()
                    self.work = nil
                }
                self.work = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: work)
            }
            completed.toggle()
        }
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectsView(tab: .constant(0))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
