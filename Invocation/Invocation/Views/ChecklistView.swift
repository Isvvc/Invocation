//
//  ChecklistView.swift
//  Invocation
//
//  Created by Isaac Lyons on 10/29/20.
//

import SwiftUI
import CoreData

struct ChecklistView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.editMode) private var editMode
    
    @EnvironmentObject private var checklistController: ChecklistController
    
    private var itemsFetchRequest: FetchRequest<Item>
    private var items: FetchedResults<Item> {
        itemsFetchRequest.wrappedValue
    }
    
    @ObservedObject var checklist: Checklist
    
    @State private var title: String
    @State private var newItem: Item?
    @State private var project: Project?
    
    init(checklist: Checklist) {
        self.checklist = checklist
        self.itemsFetchRequest = FetchRequest(
            fetchRequest: checklist.itemsFetchRequest(),
            animation: .default)
        _title = .init(wrappedValue: checklist.wrappedTitle)
    }
    
    var newItemDoneButton: some View {
        Button("Done") {
            newItem = nil
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Checklist Title", text: $title, onCommit: {
                    checklist.title = title
                    PersistenceController.save(context: moc)
                })
                .autocapitalization(.words)
            }
            
            Section(header: Text("Items")) {
                ForEach(items) { item in
                    ItemCell(item: item)
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
                
                Button(action: createItem) {
                    HStack {
                        Spacer()
                        Text("Add New Item")
                        Spacer()
                    }
                }
                .sheet(item: $newItem) { newItem in
                    NavigationView {
                        ItemView(item: newItem)
                            .navigationBarItems(leading: newItemDoneButton)
                    }
                    .environment(\.managedObjectContext, moc)
                    .environmentObject(checklistController)
                }
            }
            
            Section(header: Text("Settings")) {
                Toggle("Show completed items", isOn: $checklist.showComplete)
                Toggle("Show only one item", isOn: $checklist.showOne)
            }
            
            Button("Invoke", action: invoke)
        }
        .navigationTitle(checklist.wrappedTitle ??? "Checklist")
        .navigationBarItems(trailing: EditButton())
        .sheet(item: $project) { project in
            NavigationView {
                ProjectView(project: project)
            }
            .environment(\.managedObjectContext, moc)
            .environmentObject(checklistController)
        }
    }
    
    func createItem() {
        let newItem = Item(context: moc)
        newItem.checklist = checklist
        newItem.index = Int16(items.count)
        self.newItem = newItem
    }
    
    func delete(_ indexSet: IndexSet) {
        // I have no idea why this isn't already
        // being done on the main thread, but it
        // crashes when saving if this isn't here.
        DispatchQueue.main.async {
            indexSet.map { items[$0] }.forEach(moc.delete)
            PersistenceController.save(context: moc)
            checklist.updateIndices(items: items)
        }
    }
    
    func move(_ indices: IndexSet, newOffset: Int) {
        var itemIndices = items.enumerated().map { $0.offset }
        itemIndices.move(fromOffsets: indices, toOffset: newOffset)
        itemIndices.enumerated().compactMap { $0.element != $0.offset ? (item: items[$0.element], newIndex: Int16($0.offset)) : nil }.forEach { $0.item.index = $0.newIndex }
        
        PersistenceController.save(context: moc)
    }
    
    private func invoke() {
        project = checklistController.invoke(checklist, context: moc)
    }
}

fileprivate struct ItemCell: View {
    @ObservedObject var item: Item
    
    var body: some View {
        NavigationLink(destination: ItemView(item: item)) {
            Text(item.wrappedName ??? "Item")
                .foregroundColor(item.name != nil ? .primary : .secondary)
        }
    }
}

struct ChecklistView_Previews: PreviewProvider {
    static var checklist: Checklist {
        let fetchRequest: NSFetchRequest<Checklist> = Checklist.fetchRequest()
        fetchRequest.fetchLimit = 1
        let context = PersistenceController.preview.container.viewContext
        return try! context.fetch(fetchRequest).first!
    }
    
    static var previews: some View {
        NavigationView {
            ChecklistView(checklist: checklist)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
