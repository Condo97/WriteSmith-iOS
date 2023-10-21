//
//  WriteSmith_SwiftUIApp.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/20/23.
//

import SwiftUI

@main
struct WriteSmith_SwiftUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
