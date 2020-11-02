//
//  ProjectsView.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/2/20.
//

import SwiftUI

struct ProjectsView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)],
        animation: .default)
    private var projects: FetchedResults<Project>
    
    var body: some View {
        List {
            ForEach(projects) { project in
                HStack {
                    Text(project.wrappedTitle ??? "Project")
                    Spacer()
                    Text("\(project.tasks?.count ?? 0) tasks")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Invocations")
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectsView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
