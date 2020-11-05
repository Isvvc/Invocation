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
    
    @EnvironmentObject private var checklistController: ChecklistController
    
    //MARK: Body
    
    var body: some View {
        Form {
            Section(header: Text("Preferences")) {
                Toggle(isOn: $projectNameFill) {
                    VStack(alignment: .leading) {
                        Text("Auto fill invocation name")
                        Text("Copy a checklist's name to invocations")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            
            Section(header: Text("Date Format")) {
                Picker("Date style", selection: $dateStyle) {
                    VStack(alignment: .leading) {
                        Text("Short")
                        Text(dateFormatterShort.string(from: Date()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(1)
                    
                    VStack(alignment: .leading) {
                        Text("Medium")
                        Text(dateFormatterMedium.string(from: Date()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(2)
                    
                    VStack(alignment: .leading) {
                        Text("Long")
                        Text(dateFormatterLong.string(from: Date()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(3)
                }
                .onChange(of: dateStyle){ dateStyle in
                    checklistController.setDateFormat(dateStyleInt: dateStyle, timeStyleInt: timeStyle)
                }
                
                Picker("Time style", selection: $timeStyle) {
                    VStack(alignment: .leading) {
                        Text("Short")
                        Text(timeFormatterShort.string(from: Date()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(1)
                    
                    VStack(alignment: .leading) {
                        Text("Medium")
                        Text(timeFormatterMedium.string(from: Date()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(2)
                    
                    VStack(alignment: .leading) {
                        Text("Long")
                        Text(timeFormatterLong.string(from: Date()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(3)
                }
                .onChange(of: timeStyle){ timeStyle in
                    checklistController.setDateFormat(dateStyleInt: dateStyle, timeStyleInt: timeStyle)
                }
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
