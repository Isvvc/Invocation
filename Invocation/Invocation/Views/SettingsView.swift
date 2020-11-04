//
//  SettingsView.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/4/20.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage(Defaults.projectNameFill.rawValue) var projectNameFill: Bool = false
    
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
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
