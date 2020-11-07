//
//  SettingsView.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/4/20.
//

import SwiftUI
import SwiftDate

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
    
    @EnvironmentObject private var checklistController: ChecklistController
    
    //MARK: Body
    
    var body: some View {
        Form {
            Section(header: Text("Preferences")) {
                Toggle(isOn: $projectNameFill) {
                    TextWithCaption(
                        text: "Auto fill invocation name",
                        caption: "Copy a checklist's name to invocations")
                }
            }
            
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
            
            Section(header: Text("Date Format")) {
                Picker("Date style", selection: $dateStyle) {
                    TextWithCaption(text: "Short", caption: dateFormatterShort.string(from: Date()))
                    .tag(1)
                    
                    TextWithCaption(text: "Medium", caption: dateFormatterMedium.string(from: Date()))
                    .tag(2)
                    
                    TextWithCaption(text: "Long", caption: dateFormatterLong.string(from: Date()))
                    .tag(3)
                }
                .onChange(of: dateStyle){ dateStyle in
                    checklistController.setDateFormat(dateStyleInt: dateStyle, timeStyleInt: timeStyle)
                }
                
                Picker("Time style", selection: $timeStyle) {
                    TextWithCaption(text: "Short", caption: timeFormatterShort.string(from: Date()))
                        .tag(1)
                    
                    TextWithCaption(text: "Medium", caption: timeFormatterMedium.string(from: Date()))
                    .tag(2)
                    
                    TextWithCaption(text: "Long", caption: timeFormatterLong.string(from: Date()))
                    .tag(3)
                }
                .onChange(of: timeStyle){ timeStyle in
                    checklistController.setDateFormat(dateStyleInt: dateStyle, timeStyleInt: timeStyle)
                }
                
                Picker("Week starts on", selection: $weekStartsOn) {
                    ForEach(weekDays, id: \.self) { weekday in
                        Text(weekday.name())
                            .tag(weekday.rawValue)
                    }
                }
            }
            
            Section(header: Text("Show dates"), footer: Text("Show dates of completed tasks")) {
                Toggle("Invocations list", isOn: $showDateOnList)
                Toggle("Invocation sheet", isOn: $showDateOnProject)
            }
            
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

//MARK: Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .previewDevice("iPhone 6S")
        }
    }
}
