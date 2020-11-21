//
//  StringPicker.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/13/20.
//

import SwiftUI

struct StringPicker: View {
    
    var title: String
    var strings: [String]
    var customLimit: Int = 0
    @Binding var selection: String
    var onChange: (String) -> Void = {_ in}
    
    @State private var showingList = false
    @State private var custom = ""
    
    var list: some View {
        List {
            Section {
                ForEach(strings, id: \.self) { string in
                    Button {
                        selection = string
                        showingList = false
                        onChange(selection)
                    } label: {
                        HStack {
                            Text(string)
                            if selection == string {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            
            if customLimit > 0 {
                Section {
                    HStack {
                        TextField("Custom", text: $custom, onCommit: {
                            guard !custom.isEmpty else { return }
                            if custom.count > customLimit {
                                custom = String(custom.prefix(customLimit))
                                selection = custom
                                onChange(selection)
                            } else {
                                selection = custom
                                showingList = false
                                onChange(selection)
                            }
                        })
                        if selection == custom {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(title)
        .onAppear {
            if strings.firstIndex(of: selection) == nil {
                custom = selection
            }
        }
    }
    
    var body: some View {
        NavigationLink(destination: list, isActive: $showingList) {
            HStack {
                Text(title)
                if let selection = selection {
                    Spacer()
                    Text(selection)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct StringPicker_Previews: PreviewProvider {
    static var previews: some View {
        StringPicker(title: "Picker", strings: ["/", ".", "-"], selection: .constant("/"))
    }
}
