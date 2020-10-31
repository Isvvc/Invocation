//
//  ChecklistView.swift
//  Invocation
//
//  Created by Isaac Lyons on 10/29/20.
//

import SwiftUI
import CoreData

struct ChecklistView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @ObservedObject var checklist: Checklist
    
    var body: some View {
        List {
        }
        .navigationTitle(checklist.title ?? "Checklist")
    }
}

struct ChecklistView_Previews: PreviewProvider {
    static var checklist: Checklist {
        let fetchRequest: NSFetchRequest<Checklist> = Checklist.fetchRequest()
        fetchRequest.fetchLimit = 1
        let context = PersistenceController.preview.container.viewContext
        return try! context.fetch(fetchRequest).first!
    }
    
    static var previews: some View {
        NavigationView {
            ChecklistView(checklist: checklist)
        }
    }
}
