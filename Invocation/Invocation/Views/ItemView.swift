//
//  ItemView.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import SwiftUI
import CoreData
import SwiftDate

struct ItemView: View {
    @Environment(\.managedObjectContext) private var moc
    @AppStorage(Defaults.weekStartsOn.rawValue) private var weekStartsOn: Int = 2
    
    @EnvironmentObject private var checklistController: ChecklistController
    
    @ObservedObject var item: Item
    
    @State private var notes: String
    @State private var link: String
    @State private var editingLink = false
    
    init(item: Item) {
        self.item = item
        _notes = .init(initialValue: item.wrappedNotes)
        _link = .init(initialValue: item.link?.absoluteString ?? "")
    }
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Item Name", text: $item.wrappedName, onCommit: save)
            }
            
            Section(header: Text("Notes")) {
                TextEditor(text: $notes.animation())
                if notes != item.wrappedNotes {
                    Button("Save changes") {
                        withAnimation {
                            item.notes = notes
                            save()
                        }
                    }
                }
            }
            
            Section(header: Text("Link")) {
                HStack {
                    TextField("https://example.com/", text: $link.animation(), onEditingChanged: { editing in
                        editingLink = editing
                    }, onCommit: saveLink)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    
                    if !editingLink,
                       let link = item.link {
                        Link(destination: link) {
                            Image(systemName: "arrow.up.right")
                        }
                    } else {
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section(header: Text("Due Date")) {
                Picker("Weekday", selection: $item.weekday) {
                    Text("None")
                        .tag(Int16(0))
                    ForEach(weekdays(), id: \.self) { weekday in
                        Text(weekday.name())
                            .tag(Int16(weekday.rawValue))
                    }
                }
            }
        }
        .navigationTitle("Item")
    }
    
    func saveLink() {
        if link.isEmpty {
            item.link = nil
            return save()
        }
        
        let httpsLink = checklistController.https(link)
        
        guard let url = URL(string: httpsLink) else {
            link = item.link?.absoluteString ?? ""
            return save()
        }
        
        link = httpsLink
        item.link = url
        save()
    }
    
    func save() {
        PersistenceController.save(context: moc)
    }
    
    func weekdays() -> [WeekDay] {
        IndexSet(1...7).compactMap { WeekDay.init(rawValue: ($0 + weekStartsOn - 2) % 7 + 1) }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var item: Item {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.fetchLimit = 1
        let context = PersistenceController.preview.container.viewContext
        return try! context.fetch(fetchRequest).first!
    }
    
    static var previews: some View {
        NavigationView {
            ItemView(item: item)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(ChecklistController())
        }
    }
}
