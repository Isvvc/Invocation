//
//  ProjectsView.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import SwiftUI

//MARK: ProjectsView

struct ProjectsView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)],
        animation: .default)
    private var projects: FetchedResults<Project>
    
    @EnvironmentObject private var checklistController: ChecklistController
    
    @Binding var tab: Int
    
    @State private var selection: Project?
    
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
                        ProjectSection(project: project, selection: $selection)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Invocations")
        .sheet(item: $selection) { project in
            NavigationView {
                ProjectView(project: project)
            }
            .environment(\.managedObjectContext, moc)
            .environmentObject(checklistController)
        }
    }
}

//MARK: ProjectSection

fileprivate struct ProjectSection: View {
    
    private var tasksFetchRequest: FetchRequest<Task>
    private var tasks: FetchedResults<Task> {
        tasksFetchRequest.wrappedValue
    }
    private var task: [Task] {
        guard let task = tasks.first(where: { $0.completed == nil }) else { return [] }
        return [task]
    }
    
    @ObservedObject var project: Project
    
    @Binding var selection: Project?
    @State private var expanded = true
    
    init(project: Project, selection: Binding<Project?>) {
        self.project = project
        _selection = selection
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
        HStack {
            Spacer()
            Button {
                selection = project
            } label: {
                Text("Details")
                Image(systemName: "chevron.forward")
            }
        }
    }
    
    var body: some View {
        Section(header: header, footer: footer) {
            if expanded {
                if !project.showOne {
                    ForEach(tasks) { task in
                        TaskCell(task: task, showComplete: project.showComplete)
                    }
                } else {
                    ForEach(task) { task in
                        TaskCell(task: task, showComplete: project.showComplete)
                    }
                }
            }
        }
    }
}

//MARK: TaskCell

fileprivate struct TaskCell: View {
    @Environment(\.managedObjectContext) private var moc
    
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
                Spacer()
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
                    PersistenceController.save(context: moc)
                    // Give time for the cell to disappear
                    // before the strikethrough hides.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.completed = false
                    }
                }
                self.work = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: work)
            }
            completed.toggle()
        }
    }
}

//MARK: Preview

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectsView(tab: .constant(0))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
