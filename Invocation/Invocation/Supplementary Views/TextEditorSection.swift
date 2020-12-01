//
//  TextEditorSection.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/9/20.
//

import SwiftUI

struct TextEditorSection: View {
    var header: some View = Text("Notes")
    @Binding var text: String
    var onSave: () -> Void = {}
    
    @State private var editorText = ""
    @State private var editorTextInitialized = false
    
    var body: some View {
        Section(header: header) {
            TextEditor(text: $editorText.animation())
            if editorTextInitialized && editorText != text {
                HStack {
                    Text("Save changes")
                        .onTapGesture(perform: save)
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                        .onTapGesture(perform: reset)
                }
                .foregroundColor(.accentColor)
            }
        }
        .onAppear {
            if !editorTextInitialized {
                editorText = text
                editorTextInitialized = true
            }
        }
    }
    
    private func save() {
        hideKeyboard()
        withAnimation {
            text = editorText
            onSave()
        }
    }
    
    private func reset() {
        hideKeyboard()
        withAnimation {
            editorText = text
        }
    }
}

struct TextEditorSaveButton_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            TextEditorSection(text: .constant("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam vitae lacus odio."))
        }
    }
}
