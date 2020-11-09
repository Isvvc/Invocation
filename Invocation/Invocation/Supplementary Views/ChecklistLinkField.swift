//
//  ChecklistLinkField.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/9/20.
//

import SwiftUI

struct ChecklistLinkField: View {
    // Important! A ChecklistController must be in the envirenment.
    @EnvironmentObject private var checklistController: ChecklistController
    
    @Binding var url: URL?
    
    var onCommit: () -> Void = {}
    
    @State private var link: String = ""
    @State private var linkInitialized = false
    @State private var editingLink = false
    
    var body: some View {
        HStack {
            TextField("https://example.com/", text: $link.animation(), onEditingChanged: { editing in
                editingLink = editing
            }, onCommit: saveLink)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            
            if !editingLink,
               let link = url {
                Link(destination: link) {
                    Image(systemName: "arrow.up.right")
                }
            } else {
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            if !linkInitialized {
                link = url?.absoluteString ?? ""
                linkInitialized = true
            }
        }
    }
    
    private func saveLink() {
        if link.isEmpty {
            url = nil
            return onCommit()
        }
        
        let httpsLink = checklistController.https(link)
        
        guard let url = URL(string: httpsLink) else {
            link = self.url?.absoluteString ?? ""
            return onCommit()
        }
        
        link = httpsLink
        self.url = url
        onCommit()
    }
}

struct LinkField_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistLinkField(url: .constant(URL(string: "https://apple.com/")))
    }
}
