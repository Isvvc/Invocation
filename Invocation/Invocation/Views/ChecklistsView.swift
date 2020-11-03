//
//  ChecklistsView.swift
//  Invocation
//
//  Created by Isaac Lyons on 10/29/20.
//

import SwiftUI
import CoreData

struct ChecklistsView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Checklist.title, ascending: true)],
        animation: .default)
    private var checklists: FetchedResults<Checklist>
    
    @EnvironmentObject private var checklistController: ChecklistController
    
    @State private var newChecklist: Checklist?
    
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
    
    var body: some View {
        List {
            ForEach(checklists) { checklist in
                NavigationLink(destination: ChecklistView(checklist: checklist)) {
                    HStack {
                        Text(checklist.wrappedTitle ??? "Checklist")
                            .foregroundColor(checklist.title != nil ? .primary : .secondary)
                        Spacer()
                        Text("\(checklist.items?.count ?? 0) Items")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: delete)
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Checklists")
        .navigationBarItems(trailing: addButton)
    }
    
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
