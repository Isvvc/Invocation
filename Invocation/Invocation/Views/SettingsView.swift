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
    @AppStorage(Defaults.showDateOnList.rawValue) private var showDateOnList: Bool = true
    @AppStorage(Defaults.showDateOnProject.rawValue) private var showDateOnProject: Bool = true
    @AppStorage(Defaults.projectSort.rawValue) private var projectSort: Int = 0
    @AppStorage(Defaults.projectSortAscending.rawValue) private var projectSortAscending: Bool = true
    @AppStorage(Defaults.projectSortEmptyFirst.rawValue) private var projectSortEmptyFirst: Bool = false
    @AppStorage(Defaults.weekStartsOn.rawValue) private var weekStartsOn: Int = 2
    @AppStorage(Defaults.advancedDateFormat.rawValue) private var advancedDateFormat: Bool = false
    @AppStorage(Defaults.dateStyle.rawValue) private var dateStyle: Int = 1
    @AppStorage(Defaults.dateOrder.rawValue) private var dateOrder: Int = 0
    @AppStorage(Defaults.dateTimeOrder.rawValue) private var dateTimeOrder: Int = 0
    @AppStorage(Defaults.showYear.rawValue) private var showYear = true
    @AppStorage(Defaults.showWeekday.rawValue) private var showWeekday = true
    @AppStorage(Defaults.monthFormat.rawValue) private var monthFormat: Int = 0
    @AppStorage(Defaults.dateSeparator.rawValue) private var dateSeparator = "/"
    @AppStorage(Defaults.dateTimeSeparator.rawValue) private var dateTimeSeparator = " "
    
    @EnvironmentObject private var checklistController: ChecklistController
    
    private var dateDragObject = HorizontalDragObject(count: 3)
    private var dateTimeDragObject = HorizontalDragObject(count: 3)
    
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
                if !advancedDateFormat {
                    Picker("Date style", selection: $dateStyle) {
                        TextWithCaption(text: "Short", caption: dateFormatterShort.string(from: Date()))
                        .tag(1)
                        
                        TextWithCaption(text: "Medium", caption: dateFormatterMedium.string(from: Date()))
                        .tag(2)
                        
                        TextWithCaption(text: "Long", caption: dateFormatterLong.string(from: Date()))
                        .tag(3)
                        
                        TextWithCaption(text: "Full", caption: dateFormatterFull.string(from: Date()))
                        .tag(4)
                    }
                    .onChange(of: dateStyle, perform: checklistController.setDateStyle)
                }
                
                Toggle("Show advanced options", isOn: $advancedDateFormat.animation())
                    .onChange(of: advancedDateFormat, perform: checklistController.setAdvancedFormat)
                
                if advancedDateFormat {
                    HorizontalReorder(dragObject: dateDragObject) { dragObject, _ in
                        dateOrder = dragObject.encode()
                        checklistController.setDateFormat(dragObject.positions)
                    } item: { index in
                        ZStack {
                            // Tertiary system fill is the the background of the
                            // segmented picker below, but it is translucent.
                            // Secondary system grouped background is the
                            // background of the list cells, so placing it
                            // behind the system fill makes the item opaque.
                            Color(.secondarySystemGroupedBackground)
                            Color(.tertiarySystemFill)
                            switch index {
                            case 0: Text("Month")
                            case 1: Text("Day")
                            default:CheckboxView(title: "Year", checked: $showYear)
                                .imageScale(.large)
                            }
                        }
                    }
                    .background(
                        HStack {
                            let separator = monthFormat < 2 && dateSeparator.count == 1 ? dateSeparator : " "
                            Spacer()
                            Text(separator)
                                .foregroundColor(!showYear && dateDragObject.positions[2] == 0 ? .secondary : .primary)
                            Spacer()
                            Text(separator)
                                .foregroundColor(!showYear && 1...2 ~= dateDragObject.positions[2] ? .secondary : .primary)
                            Spacer()
                        }
                    )
                    .onAppear {
                        dateDragObject.decode(lehmerCode: dateOrder)
                    }
                    .onChange(of: showYear, perform: checklistController.setShowYear)
                    
                    Picker("Month", selection: $monthFormat.animation()) {
                        Text("1")
                            .tag(0)
                        Text("01")
                            .tag(1)
                        Text("Jan")
                            .tag(2)
                        Text("January")
                            .tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: monthFormat, perform: checklistController.setMonthFormat)
                    
                    if monthFormat < 2 {
                        StringPicker(title: "Separator", strings: ["/", ".", "-"], customLimit: 3, selection: $dateSeparator) { seletion in
                            checklistController.setDateSeparator(seletion)
                        }
                    }
                    
                    HorizontalReorder(dragObject: dateTimeDragObject) { dragObject, _ in
                        dateTimeOrder = dragObject.encode()
                        checklistController.setDateTimeFormat(dragObject.positions)
                    } item: { index in
                        ZStack {
                            Color(.secondarySystemGroupedBackground)
                            Color(.tertiarySystemFill)
                            switch index {
                            case 0: CheckboxView(title: "Weekday", spacing: 2, checked: $showWeekday)
                                .minimumScaleFactor(0.5)
                                .padding(4)
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
                    .onAppear {
                        dateTimeDragObject.decode(lehmerCode: dateTimeOrder)
                    }
                    .onChange(of: showWeekday, perform: checklistController.setShowWeekday)
                }
                
                Text(checklistController.datePreview)
            }
            
            //MARK: Show dates
            
            Section(header: Text("Show dates"), footer: Text("Show dates under tasks")) {
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
    
    private var dateFormatterFull: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }
    
}

//MARK: Checkbox view

private struct CheckboxView: View {
    var title: String
    var spacing: CGFloat?
    @Binding var checked: Bool
    
    var body: some View {
        HStack(spacing: spacing) {
            Text(title)
                .foregroundColor(checked ? .primary : .secondary)
            Image(systemName: checked ? "checkmark.square" : "square")
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
                .environmentObject(ChecklistController())
        }
    }
}
