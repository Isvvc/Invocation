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
    
    private var addButton: some View {
        Button() {
            let newChecklist = Checklist(context: moc)
            newChecklist.title = String(UUID().uuidString.prefix(8))
            PersistenceController.save(context: moc)
        } label: {
            Image(systemName: "plus")
                .imageScale(.large)
                .font(.body)
        }
    }
    
    var body: some View {
        List {
            ForEach(checklists) { checklist in
                NavigationLink(checklist.title ?? "Checklist", destination: ChecklistView(checklist: checklist))
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
