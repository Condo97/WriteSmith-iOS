//
//  V4_2MigrationHandler.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/2/23.
//

import CoreData
import Foundation

class V4_2MigrationHandler {
    
    static func migrate(in context: NSManagedObjectContext) async throws {
        // Set essay essay to editedEssay
        
        // Get all essays
        let essaysFetchRequest = Essay.fetchRequest()
        let essays = try context.fetch(essaysFetchRequest)
        
        // Set each editedEssay to essay if nil or empty
        for essay in essays {
            if essay.editedEssay == nil || essay.editedEssay!.isEmpty {
                essay.editedEssay = essay.essay
            }
        }
        
        try await context.perform {
            try context.save()
        }
    }
    
}
