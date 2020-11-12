//
//  SettingsView.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/4/20.
//

import SwiftUI
import SwiftDate
import HorizontalReorder

struct SettingsView: View {
    
    //MARK: Properties
    
    @AppStorage(Defaults.projectNameFill.rawValue) private var projectNameFill: Bool = false
    @AppStorage(Defaults.dateStyle.rawValue) private var dateStyle: Int = 1
    @AppStorage(Defaults.timeStyle.rawValue) private var timeStyle: Int = 1
    @AppStorage(Defaults.showDateOnList.rawValue) private var showDateOnList: Bool = true
    @AppStorage(Defaults.showDateOnProject.rawValue) private var showDateOnProject: Bool = true
    @AppStorage(Defaults.projectSort.rawValue) private var projectSort: Int = 0
    @AppStorage(Defaults.projectSortAscending.rawValue) private var projectSortAscending: Bool = true
    @AppStorage(Defaults.projectSortEmptyFirst.rawValue) private var projectSortEmptyFirst: Bool = false
    @AppStorage(Defaults.weekStartsOn.rawValue) private var weekStartsOn: Int = 2
    @AppStorage(Defaults.showYear.rawValue) private var showYear = true
    @AppStorage(Defaults.showWeekday.rawValue) private var showWeekday = true
    
    @EnvironmentObject private var checklistController: ChecklistController
    
    private var dragObject = HorizontalDragObject(count: 3)
    
    //MARK: Body
    
    var body: some View {
        Form {
            
            //MARK: Preferences
            
            Section(header: Text("Preferences")) {
                Toggle(isOn: $projectNameFill) {
                    TextWithCaption(
                        text: "Auto fill invocation name",
                        caption: "Copy a checklist's name to invocations")
                }
            }
            
            //MARK: Sorting
            
            Section(header: Text("Invocation Sorting")) {
                Picker("Sort by", selection: $projectSort) {
                    Text("Invocation date")
                        .tag(0)
                    Text("Name")
                        .tag(1)
                    Text("Last completed task")
                        .tag(2)
                }
                Toggle(isOn: $projectSortAscending) {
                    TextWithCaption(text: "Ascending", caption: sortDescriptions[projectSort]?[projectSortAscending])
                }
                if projectSort == 2 {
                    HStack {
                        TextWithCaption(text: "Empty invocations", caption: "Invocations with no completed tasks")
                        Picker("Empty invocations", selection: $projectSortEmptyFirst) {
                            Text("First")
                                .tag(true)
                            Text("Last")
                                .tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
            }
            
            //MARK: Date format
            
            Section(header: Text("Date Format")) {
                HorizontalReorder(dragObject: dragObject) { index in
                    ZStack {
                        Color(.secondarySystemBackground)
                        switch index {
                        case 0: Text("Month")
                        case 1: Text("Day")
                        default:CheckboxView(title: "Year", checked: $showYear)
                        }
                    }
                }
                .background(
                    HStack {
                        Spacer()
                        Text("/")
                            .foregroundColor(!showYear && dragObject.positions[2] == 0 ? .secondary : .primary)
                        Spacer()
                        Text("/")
                            .foregroundColor(!showYear && 1...2 ~= dragObject.positions[2] ? .secondary : .primary)
                        Spacer()
                    }
                )
                
                HorizontalReorder(count: 3) { index in
                    ZStack {
                        Color(.secondarySystemBackground)
                        switch index {
                        case 0: CheckboxView(title: "Weekday", checked: $showWeekday)
                            .minimumScaleFactor(0.5)
                        case 1: Text("Date")
                        default:Text("Time")
                        }
                    }
                }
                
                Picker("Week starts on", selection: $weekStartsOn) {
                    ForEach(weekDays, id: \.self) { weekday in
                        Text(weekday.name())
                            .tag(weekday.rawValue)
                    }
                }
            }
            
            //MARK: Show dates
            
            Section(header: Text("Show dates"), footer: Text("Show dates of completed tasks")) {
                Toggle("Invocations list", isOn: $showDateOnList)
                Toggle("Invocation sheet", isOn: $showDateOnProject)
            }
            
            //MARK: Acknowledgements
            
            Section {
                NavigationLink("Acknowledgements", destination: AcknowledgementsView())
            }
        }
        .navigationTitle("Settings")
    }
    
    //MARK: Descriptions
    
    private var sortDescriptions: [Int: [Bool: String]] = [
        0: [ // Invocation Date
            true: "Oldest first",
            false: "Newest first"
        ],
        1: [ // Name
            true: "A-Z",
            false: "Z-A"
        ],
        2: [ // Last completed task
            true: "Last completed last",
            false: "Last completed first"
        ]
    ]
    
    private let weekDays: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    
    //MARK: Date Formatters
    
    // I feel like I shoudln't have to do this but
    // idk how else to get 6 different date formats.
    
    private var dateFormatterShort: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
    
    private var dateFormatterMedium: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private var dateFormatterLong: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }
    
    private var timeFormatterShort: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
    
    private var timeFormatterMedium: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }
    
    private var timeFormatterLong: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .long
        return formatter
    }
    
}

private struct CheckboxView: View {
    var title: String
    @Binding var checked: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(checked ? .primary : .secondary)
            Image(systemName: checked ? "checkmark.square" : "square")
                .imageScale(.large)
                .foregroundColor(checked ? .accentColor : .secondary)
        }
        .onTapGesture {
            withAnimation {
                checked.toggle()
            }
        }
    }
}

//MARK: Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .previewDevice("iPhone 6S")
        }
    }
}
