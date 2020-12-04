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
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Checklist.title, ascending: true)],
        animation: .default)
    private var checklists: FetchedResults<Checklist>
    
    @EnvironmentObject private var checklistController: ChecklistController
    
    @State private var selection: Checklist?
    @State private var newChecklist: Checklist?
    @State private var project: Project?
    
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
                ChecklistView(checklist: newChecklist)
                    .environment(\.managedObjectContext, moc)
                    .environmentObject(checklistController)
            }
            // I have no idea why, but everything is bold if I don't add this
            .font(.body)
        }
    }
    
    //MARK: Body
    
    var body: some View {
        List {
            ForEach(checklists) { checklist in
                HStack {
                    Button {
                        project = checklistController.invoke(checklist, context: moc)
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
                    
                    Button {
                        selection = checklist
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .imageScale(.large)
                    }
                    
                    NavigationLink(
                        destination: ChecklistView(checklist: checklist),
                        tag: checklist,
                        selection: $selection,
                        label: { EmptyView() })
                        .frame(width: 0, height: 0)
                        .opacity(0)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .onDelete(perform: delete)
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Checklists")
        .navigationBarItems(trailing: addButton)
        .sheet(item: $project) { project in
            NavigationView {
                ProjectView(project: project)
            }
            .environment(\.managedObjectContext, moc)
            .environmentObject(checklistController)
        }
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
            ChecklistsView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
