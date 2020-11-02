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
    
    private var itemsFetchRequest: FetchRequest<Item>
    private var items: FetchedResults<Item> {
        itemsFetchRequest.wrappedValue
    }
    
    @ObservedObject var checklist: Checklist
    
    @State private var title: String
    
    init(checklist: Checklist) {
        self.checklist = checklist
        self.itemsFetchRequest = FetchRequest(
            fetchRequest: checklist.itemsFetchRequest(),
            animation: .default)
        _title = .init(wrappedValue: checklist.wrappedTitle)
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
            
            ForEach(items) { item in
                HStack {
                    Text(item.name ?? "Item")
                    Spacer()
                    Text("\(item.index)")
                        .foregroundColor(.secondary)
                }
            }
            .onDelete { indexSet in
                // I have no idea why this isn't already
                // being done on the main thread, but it
                // crashes when saving if this isn't here.
                DispatchQueue.main.async {
                    withAnimation {
                        indexSet.map { items[$0] }.forEach { moc.delete($0) }
                    }
                    PersistenceController.save(context: moc)
                    checklist.updateIndices(items: items)
                }
            }
            .onMove { indices, newOffset in
                var itemIndices = items.enumerated().map { $0.offset }
                itemIndices.move(fromOffsets: indices, toOffset: newOffset)
                itemIndices.enumerated().compactMap { $0.element != $0.offset ? (item: items[$0.element], newIndex: Int16($0.offset)) : nil }.forEach { $0.item.index = $0.newIndex }
                
                PersistenceController.save(context: moc)
            }
            
            Button(action: createItem) {
                HStack {
                    Spacer()
                    Text("Add New Item")
                    Spacer()
                }
            }
            
            Section(header: Text("Settings")) {
                Toggle("Show completed items", isOn: $checklist.showComplete)
                Toggle("Show only one item", isOn: $checklist.showOne)
            }
        }
        .navigationTitle(checklist.title ?? "Checklist")
        .navigationBarItems(trailing: EditButton())
    }
    
    func createItem() {
        let newItem = Item(context: moc)
        newItem.name = String(UUID().uuidString.prefix(8))
        newItem.checklist = checklist
        newItem.index = Int16(items.count)
        PersistenceController.save(context: moc)
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
