//
//  WriteSmith_WatchApp_SelfContainedApp.swift
//  WriteSmith_WatchApp_SelfContained Watch App
//
//  Created by Alex Coundouriotis on 11/4/23.
//

import SwiftUI

@main
struct WriteSmith_WatchApp: App {
    
    @StateObject private var premiumUpdater: PremiumUpdater = PremiumUpdater()
    @StateObject private var remainingUpdater: RemainingUpdater = RemainingUpdater()
    
    
    var body: some Scene {
        WindowGroup {
            ConversationView()
                .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
                .environmentObject(remainingUpdater)
                .environmentObject(premiumUpdater)
        }
    }
    
}
