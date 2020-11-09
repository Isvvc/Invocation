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
    
    @State private var due = false
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Item name", text: $item.wrappedName, onCommit: save)
            }
            
            TextEditorSection(text: $item.wrappedNotes, onSave: save)
            
            Section(header: Text("Link")) {
                ChecklistLinkField(url: $item.link, onCommit: save)
            }
            
            Section {
                Toggle("Due date", isOn: $due.animation())
                    .onChange(of: due) { value in
                        item.due = value
                    }
                
                if due {
                    Picker("Weekday", selection: $item.weekday) {
                        Text("None")
                            .tag(Int16(0))
                        ForEach(weekdays(), id: \.self) { weekday in
                            Text(weekday.name())
                                .tag(Int16(weekday.rawValue))
                        }
                    }
                    
                    Stepper(value: $item.dateOffset, in: 0...365) {
                        HStack {
                            TextWithCaption(text: "Day offset", caption: dateOffsetCaption())
                            Spacer()
                            Text("\(item.dateOffset)")
                        }
                    }
                    
                    DatePicker("Time", selection: $item.wrappedTime, displayedComponents: .hourAndMinute)
                    
                    HStack {
                        Text("Next due date")
                        Spacer()
                        Text(checklistController.dateFormatter.string(from: item.nextDueDate))
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .navigationTitle("Item")
        .onAppear {
            due = item.due
        }
    }
    
    func save() {
        PersistenceController.save(context: moc)
    }
    
    func weekdays() -> [WeekDay] {
        IndexSet(1...7).compactMap { WeekDay.init(rawValue: ($0 + weekStartsOn - 2) % 7 + 1) }
    }
    
    func dateOffsetCaption() -> String {
        if let weekday = WeekDay(rawValue: Int(item.weekday))?.name() {
            switch item.dateOffset {
            case 0:
                return "Next \(weekday) after invocation"
            case 1:
                return "Next \(weekday) 1 day after invocation"
            default:
                return "Next \(weekday) \(item.dateOffset) days after invocation"
            }
        } else {
            switch item.dateOffset {
            case 0:
                return "Same day as invocation"
            case 1:
                return "The day after invocation"
            default:
                return "\(item.dateOffset) days after invocation"
            }
        }
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
