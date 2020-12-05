//
//  ChecklistsView.swift
//  Invocation
//
//  Created by Isaac Lyons on 10/29/20.
//

import SwiftUI
import CoreData

struct ChecklistsView: View {
    
    //MARK: Properties
    
    @Environment(\.managedObjectContext) private var moc
    
    @AppStorage(Defaults.invokeOnTap.rawValue) private var invokeOnTap: Bool = true
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Checklist.title, ascending: true)],
        animation: .default)
    private var checklists: FetchedResults<Checklist>
    
    @EnvironmentObject private var checklistController: ChecklistController
    
    @Binding var newProject: Project?
    
    @State private var selection: Checklist?
    @State private var newChecklist: Checklist?
    
    //MARK: Views
    
    private var addButton: some View {
        Button() {
            newChecklist = Checklist(context: moc)
            PersistenceController.save(context: moc)
        } label: {
            Image(systemName: "plus")
                .imageScale(.large)
                .font(.body)
        }
        .sheet(item: $newChecklist) { newChecklist in
            NavigationView {
                ChecklistView(checklist: newChecklist, newProject: $newProject)
                    .environment(\.managedObjectContext, moc)
                    .environmentObject(checklistController)
            }
            // Because the button this is attached to is bolded,
            // the sheet contents will be bold by defualt.
            .font(.body)
        }
    }
    
    //MARK: Body
    
    var body: some View {
        List {
            ForEach(checklists) { checklist in
                HStack {
                    Button {
                        if invokeOnTap {
                            newProject = checklistController.invoke(checklist, context: moc)
                        } else {
                            selection = checklist
                        }
                    } label: {
                        HStack {
                            let items = checklist.items?.count ?? 0
                            let projects = checklist.projects?.count ?? 0
                            TextWithCaption(text: checklist.wrappedTitle ??? "Checklist", caption: "\(items) Item\(items == 1 ? "" : "s")")
                                .foregroundColor(checklist.title != nil ? .primary : .secondary)
                            Spacer()
                            Text("\(projects) invocation\(projects == 1 ? "" : "s")")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if invokeOnTap {
                        Button {
                            selection = checklist
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .imageScale(.large)
                        }
                    }
                    
                    NavigationLink(
                        destination: ChecklistView(checklist: checklist, newProject: $newProject),
                        tag: checklist,
                        selection: $selection,
                        label: { EmptyView() })
                        .frame(width: invokeOnTap ? 0 : 20)
                        .opacity(invokeOnTap ? 0 : 1)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .onDelete(perform: delete)
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Checklists")
        .navigationBarItems(trailing: addButton)
    }
    
    //MARK: Functions
    
    func delete(_ indexSet: IndexSet) {
        indexSet.map({ checklists[$0] }).forEach { checklist in
            checklist.deleteChildrenAndSelf(context: moc)
        }
        PersistenceController.save(context: moc)
    }
}

struct ChecklistsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChecklistsView(newProject: .constant(nil))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
