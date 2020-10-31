//
//  ChecklistsView.swift
//  Invocation
//
//  Created by Isaac Lyons on 10/29/20.
//

import SwiftUI

struct ChecklistsView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Checklist.title, ascending: true)],
        animation: .default)
    private var checklists: FetchedResults<Checklist>
    
    var body: some View {
        List {
            ForEach(checklists) { checklist in
                NavigationLink(checklist.title ?? "Checklist", destination: ChecklistView(checklist: checklist))
            }
        }
        .navigationTitle("Checklists")
    }
}

struct ChecklistsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChecklistsView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
