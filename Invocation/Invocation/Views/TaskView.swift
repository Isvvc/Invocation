//
//  TaskView.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/9/20.
//

import SwiftUI
import CoreData

struct TaskView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @ObservedObject var task: Task
    
    @State private var due = false
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Task name", text: $task.wrappedName, onCommit: save)
            }
            
            TextEditorSection(text: $task.wrappedNotes)
            
            Section(header: Text("Link")) {
                ChecklistLinkField(url: $task.wrappedOptionalLink, onCommit: save)
            }
            
            Section(header: Text("Due Date")) {
                HStack {
                    Toggle("Due date", isOn: $due.animation())
                        .onChange(of: due) { due in
                            if due {
                                task.resetDueDate()
                            } else {
                                task.due = nil
                            }
                        }
                    
                    if due {
                        Spacer()
                        
                        if !task.dueDateIsUnchanged {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.accentColor)
                                .onTapGesture {
                                    task.resetDueDate()
                                    save()
                                }
                        }
                        
                        DatePicker("Due date", selection: $task.wrappedDueDate)
                    }
                }
            }
            .labelsHidden()
        }
        .navigationTitle("Task")
        .onAppear {
            due = task.due != nil
        }
    }
    
    private func save() {
        PersistenceController.save(context: moc)
    }
}

struct TaskView_Previews: PreviewProvider {
    static var task: Task {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.fetchLimit = 1
        let context = PersistenceController.preview.container.viewContext
        return try! context.fetch(fetchRequest).first!
    }
    
    static var previews: some View {
        TaskView(task: task)
    }
}
