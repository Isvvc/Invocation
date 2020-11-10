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
    @State private var specificTime = true
    @State private var showingTimeOffset = false
    @State private var hourSelection: Int = 0
    @State private var minuteSelection: Int = 0
    
    var body: some View {
        ScrollViewReader { proxy in
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0625) {
                                withAnimation {
                                    proxy.scrollTo(0)
                                }
                            }
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
                        
                        Picker("Time", selection: $specificTime.animation()) {
                            Text("Time after invocation")
                                .tag(false)
                            Text("Specific time")
                                .tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: specificTime, perform: changeTimeType)
                        
                        if specificTime {
                            DatePicker("Time", selection: $item.wrappedTime, displayedComponents: .hourAndMinute)
                        } else {
                            Button {
                                withAnimation {
                                    showingTimeOffset.toggle()
                                    if showingTimeOffset {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                            withAnimation {
                                                proxy.scrollTo(0)
                                            }
                                        }
                                    }
                                }
                            } label: {
                                ZStack {
                                    HStack {
                                        if showingTimeOffset {
                                            Spacer()
                                        }
                                        Text("Time offset")
                                        Spacer()
                                    }
                                    HStack {
                                        Spacer()
                                        if !showingTimeOffset {
                                            Text(timeOffsetText)
                                                .foregroundColor(.primary)
                                        }
                                        Image(systemName: "chevron.forward")
                                            .imageScale(.large)
                                            .rotationEffect(showingTimeOffset ? .degrees(90) : .zero)
                                    }
                                }
                            }
                            
                            if showingTimeOffset {
                                TimePicker(hourSelection: $hourSelection, minuteSelection: $minuteSelection)
                                    .onChange(of: hourSelection, perform: setTimeOffset)
                                    .onChange(of: minuteSelection, perform: setTimeOffset)
                            }
                        }
                        
                        HStack {
                            Text("Next due date")
                            Spacer()
                            Text(checklistController.dateFormatter.string(from: item.nextDueDate))
                                .fontWeight(.semibold)
                        }
                        .id(0)
                    }
                }
            }
        }
        .navigationTitle("Item")
        .onAppear {
            due = item.due
            specificTime = item.time != nil
            if item.timeInterval > 1 {
                hourSelection = Int(item.timeInterval / 3600)
                minuteSelection = Int(item.timeInterval.truncatingRemainder(dividingBy: 3600) / 60)
            }
        }
    }
    
    private func save() {
        PersistenceController.save(context: moc)
    }
    
    private func weekdays() -> [WeekDay] {
        IndexSet(1...7).compactMap { WeekDay.init(rawValue: ($0 + weekStartsOn - 2) % 7 + 1) }
    }
    
    private func dateOffsetCaption() -> String {
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
    
    private func setTimeOffset(_: Any? = nil) {
        let hoursInSeconds = TimeInterval(hourSelection) * 3600
        let minutesInSeconds = TimeInterval(minuteSelection) * 60
        item.timeInterval = hoursInSeconds + minutesInSeconds
    }
    
    private var timeOffsetText: String {
        (hourSelection == 0 ? "" : "\(hourSelection) hour")
            + (hourSelection > 1 ? "s" : "")
            + (hourSelection == 0 || minuteSelection == 0 ? "" : ", ")
            + (minuteSelection == 0 ? "" : "\(minuteSelection) minute")
            + (minuteSelection > 1 ? "s" : "")
    }
    
    private func changeTimeType(_: Any? = nil) {
        if specificTime {
            if item.time == nil {
                item.time = Date() + 10.minutes
            }
        } else {
            item.time = nil
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
