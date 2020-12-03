//
//  ProjectView.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/3/20.
//

import SwiftUI
import CoreData

//MARK: Project View

struct ProjectView: View {
    
    //MARK: Properties
    
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.editMode) private var editMode
    
    @AppStorage(Defaults.projectNameFill.rawValue) var projectNameFill: Bool = false
    
    private var tasksFetchRequest: FetchRequest<Task>
    private var tasks: FetchedResults<Task> {
        tasksFetchRequest.wrappedValue
    }
    
    @EnvironmentObject private var checklistController: ChecklistController
    
    @ObservedObject var project: Project
    
    var markForDelete: (Project) -> Void
    
    @State private var title: String = ""
    @State private var selection: Task?
    @State private var delete = false
    @State private var showOne = false
    
    init(project: Project, markForDelete: @escaping (Project) -> Void = {_ in}) {
        self.project = project
        self.tasksFetchRequest = FetchRequest(
            fetchRequest: project.allTasksFetchRequest(),
            animation: .default)
        self.markForDelete = markForDelete
    }
    
    //MARK: Views
    
    private var doneButton: some View {
        Button("Done") {
            presentationMode.wrappedValue.dismiss()
        }
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
    
    //MARK: Body
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                HStack {
                    TextField(projectNameFill ? "Invocation Title" : project.checklist?.title ?? "Checklist Title", text: $title, onCommit: setTitle)
                        .autocapitalization(.words)
                    // Show the reset button if the name is modified, or
                    // if the name field is empty when it shoudn't be.
                    if project.title != nil
                        || (projectNameFill && title.isEmpty) {
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
                    TaskRow(task: task, selection: $selection)
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
            
            Section(header: settingsHeader) {
                Toggle("Show only one item", isOn: $project.showOne)
                    // In theory a .animation() on this toggle binding should animate this, but
                    // it doesn't, so I'm using a separate state variable to force animation.
                    .onChange(of: project.showOne) { showOne in
                        withAnimation {
                            self.showOne = showOne
                        }
                    }
                if !showOne {
                    Toggle("Show completed items", isOn: $project.showComplete)
                }
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
        .navigationBarItems(leading: doneButton, trailing: EditButton())
        .onAppear {
            showOne = project.showOne
            if projectNameFill {
                title = project.wrappedTitle
            } else {
                title = project.title ?? ""
            }
        }
        .onDisappear {
            PersistenceController.save(context: moc)
        }
    }
    
    //MARK: Functions
    
    func setTitle() {
        if title.isEmpty {
            if !projectNameFill {
                 project.title = nil
            }
            // Otherwise don't do anything, since
            // there shouldn't be an empty name.
        } else if title == project.checklist?.title {
            project.title = nil
            if !projectNameFill {
                title = ""
            }
        } else {
            project.title = title
        }
        
        PersistenceController.save(context: moc)
    }
    
    func resetTitle() {
        if projectNameFill {
            guard let checklistTitle = project.checklist?.title else { return }
            title = checklistTitle
        } else {
            title = ""
        }
        setTitle()
    }
    
    func deleteProject() {
        markForDelete(project)
        presentationMode.wrappedValue.dismiss()
        checklistController.delete(project, context: moc)
    }
    
    func delete(_ indexSet: IndexSet) {
        DispatchQueue.main.async {
            let tasks = indexSet.map { self.tasks[$0] }
            checklistController.delete(tasks, context: moc)
        }
    }
    
    func move(_ indices: IndexSet, newOffset: Int) {
        var taksIndices = tasks.enumerated().map { $0.offset }
        taksIndices.move(fromOffsets: indices, toOffset: newOffset)
        taksIndices.enumerated().compactMap { $0.element != $0.offset ? (task: tasks[$0.element], newIndex: Int16($0.offset)) : nil }.forEach { $0.task.index = $0.newIndex }
        
        PersistenceController.save(context: moc)
    }
}

//MARK: Task Row

fileprivate struct TaskRow: View {
    
    @EnvironmentObject private var checklistController: ChecklistController
    
    @AppStorage(Defaults.showDateOnProject.rawValue) private var showDateOnProject: Bool = true
    
    @ObservedObject var task: Task
    @Binding var selection: Task?
    
    var body: some View {
        HStack {
            NavigationLink(
                destination: TaskView(task: task),
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
                        if showDateOnProject {
                            if let completedDate = task.completed {
                                Text("Completed \(completedDate, formatter: checklistController.dateFormatter)")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            } else if let dueDate = task.due {
                                Text("Due \(dueDate, formatter: checklistController.dateFormatter)")
                                    .foregroundColor(dueDate > Date() ? .secondary : .red)
                                    .font(.caption)
                            }
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

//MARK: Preview

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
                .environmentObject(ChecklistController())
        }
    }
}
