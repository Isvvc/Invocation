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
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.editMode) private var editMode
    
    private var tasksFetchRequest: FetchRequest<Task>
    private var tasks: FetchedResults<Task> {
        tasksFetchRequest.wrappedValue
    }
    
    @ObservedObject var project: Project
    
    @State private var title: String
    @State private var selection: Task?
    @State private var delete = false
    
    init(project: Project) {
        self.project = project
        self.tasksFetchRequest = FetchRequest(
            fetchRequest: project.allTasksFetchRequest(),
            animation: .default)
        _title = .init(wrappedValue: project.wrappedTitle)
    }
    
    private var settingsHeader: some View {
        Button {
            guard let checklist = project.checklist else { return }
            project.showComplete = checklist.showComplete
            project.showOne = checklist.showOne
        } label: {
            HStack {
                Text("Settings")
                if let checklist = project.checklist {
                    if project.showComplete != checklist.showComplete
                        || project.showOne != checklist.showOne {
                        Spacer()
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                HStack {
                    TextField("Checklist Title", text: $title, onCommit: setTitle)
                        .autocapitalization(.words)
                    if project.title != nil {
                        Spacer()
                        // This isn't a button because if it was, then tapping
                        // the cell around the TextField would trigger it.
                        Image(systemName: "arrow.counterclockwise")
                            .onTapGesture(perform: resetTitle)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            Section(header: Text("Tasks")) {
                ForEach(tasks) { task in
                    TaskView(task: task, selection: $selection)
                }
            }
            
            Section(header: settingsHeader) {
                Toggle("Show completed items", isOn: $project.showComplete)
                Toggle("Show only one item", isOn: $project.showOne)
            }
            .animation(.easeInOut)
            
            Section {
                Button {
                    delete = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete")
                        Spacer()
                    }
                }
                .foregroundColor(.red)
                .actionSheet(isPresented: $delete) {
                    ActionSheet(title: Text("Are you sure?"), message: Text("Delete \(project.wrappedTitle ??? "Project")?"), buttons: [
                        .destructive(Text("Delete"), action: deleteProject),
                        .cancel()
                    ])
                }
            }
        }
        .navigationTitle(project.wrappedTitle ??? "Invocation")
        .onDisappear {
            PersistenceController.save(context: moc)
        }
    }
    
    func setTitle() {
        if title == project.checklist?.title {
            project.title = nil
        } else {
            project.title = title
        }
        PersistenceController.save(context: moc)
    }
    
    func resetTitle() {
        guard let checklistTitle = project.checklist?.title else { return }
        title = checklistTitle
        setTitle()
    }
    
    func deleteProject() {
        presentationMode.wrappedValue.dismiss()
        project.deleteChildrenAndSelf(context: moc)
        PersistenceController.save(context: moc)
    }
}

fileprivate struct TaskView: View {
    
    @EnvironmentObject private var checklistController: ChecklistController
    
    @ObservedObject var task: Task
    @Binding var selection: Task?
    
    var body: some View {
        HStack {
            NavigationLink(
                destination: Text("Task"),
                tag: task,
                selection: $selection,
                label: { EmptyView() })
                .frame(width: 0, height: 0)
            
            Button {
                task.toggle()
            } label: {
                HStack {
                    Image(systemName: task.completed != nil ? "checkmark.square" : "square")
                        .imageScale(.large)
                    VStack(alignment: .leading) {
                        Text(task.wrappedName ??? "Task")
                            .foregroundColor(.primary)
                        if let completedDate = task.completed {
                            Text("Completed \(checklistController.dateFormatter.string(from: completedDate))")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .animation(.easeInOut)
                    Spacer()
                }
            }
            
            Button {
                selection = task
            } label: {
                Image(systemName: "questionmark.circle")
                    .imageScale(.large)
            }
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var project: Project {
        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        fetchRequest.fetchLimit = 1
        // Can't seem to get the predicate right to show
        // the preview Project with the completed task.
//        fetchRequest.predicate = NSPredicate(format: "SUBQUERY(tasks, $task, $task.completed != nil).@count > 0")
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
