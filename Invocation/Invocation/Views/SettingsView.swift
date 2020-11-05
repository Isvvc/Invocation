//
//  SettingsView.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/4/20.
//

import SwiftUI

struct SettingsView: View {
    
    //MARK: Properties
    
    @AppStorage(Defaults.projectNameFill.rawValue) private var projectNameFill: Bool = false
    @AppStorage(Defaults.dateStyle.rawValue) private var dateStyle: Int = 1
    @AppStorage(Defaults.timeStyle.rawValue) private var timeStyle: Int = 1
    @AppStorage(Defaults.showDateOnList.rawValue) private var showDateOnList: Bool = true
    @AppStorage(Defaults.showDateOnProject.rawValue) private var showDateOnProject: Bool = true
    
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
            }
            
            Section(header: Text("Show dates"), footer: Text("Show dates of completed tasks")) {
                Toggle("Invocations list", isOn: $showDateOnList)
                Toggle("Invocation sheet", isOn: $showDateOnProject)
            }
        }
        .navigationTitle("Settings")
    }
    
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
