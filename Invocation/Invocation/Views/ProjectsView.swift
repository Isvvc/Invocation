//
//  ProjectsView.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import SwiftUI

//MARK: Projects View

struct ProjectsView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @EnvironmentObject private var checklistController: ChecklistController
    @EnvironmentObject var projectsContainer: ObjectsContainer<Project>
    var projects: [Project] {
        projectsContainer.sortedObjects
    }
    
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
            .onDisappear {
                withAnimation {
                    projectsContainer.update(object: project)
                }
            }
        }
    }
}

//MARK: Project Section

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
                        TaskCell(task: task, showComplete: false)
                    }
                }
            }
        }
    }
}

//MARK: Task Cell

fileprivate struct TaskCell: View {
    @Environment(\.managedObjectContext) private var moc
    
    @AppStorage(Defaults.showDateOnList.rawValue) private var showDateOnList: Bool = true
    
    @EnvironmentObject private var checklistController: ChecklistController
    @EnvironmentObject private var projectsContainer: ObjectsContainer<Project>
    
    @ObservedObject var task: Task
    
    var showComplete: Bool
    
    @State private var completed = false
    @State private var work: DispatchWorkItem?
    @State private var dateFormatter: DateFormatter?
    
    var body: some View {
        Button(action: completeTask) {
            HStack {
                if showComplete {
                    Image(systemName: task.completed != nil ? "checkmark.square" : "square")
                        .imageScale(.large)
                }
                VStack(alignment: .leading) {
                    Text(task.wrappedName ??? "Task")
                        .foregroundColor(.primary)
                    if showDateOnList,
                       let dateFormatter = dateFormatter {
                        if showComplete,
                           let completedDate = task.completed {
                            Text("Completed \(completedDate, formatter: dateFormatter)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        } else if let dueDate = task.due {
                            Text("Due \(dueDate, formatter: dateFormatter)")
                                .foregroundColor(dueDate > Date() ? .secondary : .red)
                                .font(.caption)
                        }
                    }
                }
                Spacer()
            }
        }
        .overlay(
            Rectangle()
                .frame(maxWidth: completed ? .infinity : 0, maxHeight: 1)
                .animation(.easeIn(duration: 0.125))
        )
        .onAppear {
            // The dateFormatter has to be changed for it to update.
            // If we don't set it to nil here first, it won't update
            // the date. If we instead make Checklist Controller's
            // Date Formatter a Published property and run `objectWillChange.send()`
            // before changing the date format, then the date format
            // settings will have laggy animations as every checklist
            // item has to update at once on each change.
            dateFormatter = nil
            dateFormatter = checklistController.dateFormatter
        }
    }
    
    private func completeTask() {
        if showComplete {
            task.toggle()
            updateProjectSorting()
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
                        completed = false
                        updateProjectSorting()
                    }
                }
                self.work = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: work)
            }
            completed.toggle()
        }
    }
    
    private func updateProjectSorting() {
        guard let project = task.project else { return }
        withAnimation {
            projectsContainer.update(object: project)
        }
    }
    
}

//MARK: Preview

struct ProjectsView_Previews: PreviewProvider {
    static var projectsContainer: ObjectsContainer<Project> = {
        let projectsContainer = ObjectsContainer<Project>(method: 0, ascending: true, emptyFirst: false, context: PersistenceController.preview.container.viewContext)
        
        projectsContainer.comparisons.append(
            Comparison<Project, String>(makeComparison: { project -> String? in
                project.wrappedTitle
            }))
        projectsContainer.sort()
        
        return projectsContainer
    }()
    
    static var previews: some View {
        NavigationView {
            ProjectsView(tab: .constant(0))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(projectsContainer)
        }
    }
}
