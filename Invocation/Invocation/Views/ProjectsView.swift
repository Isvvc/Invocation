//
//  ProjectsView.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import SwiftUI

//MARK: Projects View

struct ProjectsView: View {
    
    static let viewProjectType = "vc.isv.Invocation.view-project"
    
    @Environment(\.managedObjectContext) private var moc
    
    @EnvironmentObject private var checklistController: ChecklistController
    @EnvironmentObject private var projectsContainer: ObjectsContainer<Project>
    var projects: [Project] {
        projectsContainer.sortedObjects
    }
    
    @StateObject private var collapseController = CollapseController<Project>()
    
    @Binding var tab: Int
    
    @State private var selection: Project?
    @State private var toDelete: Project?
    
    var emptyHeader: some View {
        EmptyView()
            .padding(.trailing)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .listRowInsets(EdgeInsets())
            .background(Color(.systemGroupedBackground))
    }
    
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
                    // What appear to be section headers and footers in this list are actually
                    // just cells with their background color set to the grouped list background
                    // color and their separator lines removed.
                    // The issue is that this puts a line at the top and bottom of the list.
                    // By putting the entire thing in a section, we can create a header with
                    // its bottom line removed and use an actual footer for the last section
                    // instead of the pseudo-footers used for the other sections. This allows
                    // us to remove those extra separator lines at the top and bottom of the
                    // list to make the pseudo-sections look more like actual sections.
                    Section(header: emptyHeader, footer: footer(projects.last)) {
                        ForEach(projects) { project in
                            if project != toDelete {
                                ProjectSection(project: project, selection: $selection, last: project == projects.last)
                            }
                        }
                    }
                    .environmentObject(collapseController)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Invocations")
        .sheet(item: $selection) { project in
            NavigationView {
                ProjectView(project: project, markForDelete: markForDelete)
            }
            .environment(\.managedObjectContext, moc)
            .environmentObject(checklistController)
            // When the project view is dismissed, update its position in the list
            .onDisappear {
                withAnimation {
                    projectsContainer.update(object: project)
                }
            }
        }
        
        .userActivity(ProjectsView.viewProjectType, element: selection) { selection, activity in
            activity.persistentIdentifier = selection.checklist?.id?.uuidString
            activity.title = "View latest \(selection.checklist?.title ?? "Invocation") invocation"
            activity.userInfo = ["id": selection.checklist?.id?.uuidString as Any]
            
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            activity.isEligibleForHandoff = true

            print(selection.checklist?.id?.uuidString as Any)
            print("Advertising View latest \(selection.checklist?.title ?? "Invocation") invocation")
        }
        .onContinueUserActivity(ProjectsView.viewProjectType) { userActivity in
            print(userActivity.userInfo?["id"] as Any)
            guard let checklistIDString = userActivity.userInfo?["id"] as? String,
                  let checklistID = UUID(uuidString: checklistIDString) else { return }
            if let activityProject = checklistController.latestProject(ofChecklistWithID: checklistID, context: moc) {
                if selection == nil {
                    selection = activityProject
                } else {
                    // Dismiss the currently opened Project.
                    selection = nil
                    // Wait for the dismiss animation to finish.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        selection = activityProject
                    }
                }
            }
        }
    }
    
    private func markForDelete(_ project: Project) {
        withAnimation(.none) {
            toDelete = project
        }
    }
    
    private func footer(_ project: Project?) -> some View {
        HStack {
            Spacer()
            HStack {
                Text("Details")
                Image(systemName: "chevron.forward")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .onTapGesture {
                selection = project
            }
        }
        .padding(.top, 8)
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
    
    @EnvironmentObject private var collapseController: CollapseController<Project>
    
    @ObservedObject var project: Project
    
    @Binding var selection: Project?
    var last: Bool
    
    @State private var expanded = true
    
    init(project: Project, selection: Binding<Project?>, last: Bool) {
        self.project = project
        _selection = selection
        tasksFetchRequest = FetchRequest(
            fetchRequest: project.tasksFetchRequest(),
            animation: .default)
        self.last = last
    }
    
    private var header: some View {
        Button {
            let collapsed = collapseController.toggle(project)
            withAnimation(.easeInOut(duration: 0.25)) {
                expanded = !collapsed
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    Text(project.wrappedTitle ??? "Project")
                        .font(.title)
                        .foregroundColor(.primary)
                    Text("\(project.tasks?.count ?? 0) Task\(project.tasks?.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Spacer()
                Image(systemName: "chevron.forward")
                    .imageScale(.large)
                    // Using blue here instead of accentColor so it stays blue
                    // while temporarily disabled when collapsing or expanding.
                    .foregroundColor(.blue)
                    .rotationEffect(expanded ? .degrees(90) : .zero)
            }
        }
    }
    
    private var footer: some View {
        HStack {
            Spacer()
            HStack {
                Text("Details")
                Image(systemName: "chevron.forward")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .onTapGesture {
                selection = project
            }
        }
    }
    
    var body: some View {
        Group {
            header
                .listRowBackground(Color(.systemGroupedBackground))
            if !collapseController.collapsed.contains(project) {
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
            if !last {
                footer
                    // This removes the separator line from below the footer cell
                    .padding(.trailing)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .listRowInsets(EdgeInsets())
                    .background(Color(.systemGroupedBackground))
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
            DispatchQueue.main.async {
                dateFormatter = nil
                dateFormatter = checklistController.dateFormatter
            }
        }
    }
    
    private func completeTask() {
        if showComplete {
            checklistController.toggle(task)
            updateProjectSorting()
        } else {
            if completed {
                work?.cancel()
            } else {
                // Complete the task in 1 second to give time for
                // the animation to play and for the user to cancel.
                let work = DispatchWorkItem {
                    checklistController.complete(task)
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
                .environmentObject(ChecklistController())
        }
    }
}
