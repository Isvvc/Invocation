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
    
    private var itemsFetchRequest: FetchRequest<Item>
    private var items: FetchedResults<Item> {
        itemsFetchRequest.wrappedValue
    }
    
    @ObservedObject var checklist: Checklist
    
    init(checklist: Checklist) {
        self.checklist = checklist
        self.itemsFetchRequest = FetchRequest(fetchRequest: checklist.itemsFetchRequest())
    }
    
    var body: some View {
        List {
            ForEach(items) { item in
                HStack {
                    Text(item.name ?? "Item")
                    Spacer()
                    Text("\(item.index)")
                        .foregroundColor(.secondary)
                }
            }
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
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
