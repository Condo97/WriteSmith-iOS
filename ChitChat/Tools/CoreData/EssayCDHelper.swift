//
//  CDHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/21/23.
//

import CoreData
import Foundation

class EssayCDHelper: Any {
    
    static let essayEntityName = String(describing: Essay.self)
    
    static func getLastEssayID() async -> Int64? {
        do {
            //TODO: Add predicate to only get the latest object
            let essays = try await CDClient.getAll(in: essayEntityName)
            
            guard essays.count > 0 else {
                print("No essays found when getting last essay ID...")
                return nil
            }
            
            //TODO: Should this be a String or will I just get rid of this whole thing lol
            guard let id = essays[essays.count - 1].value(forKey: "id") as? Int64 else {
                print("Error converting ID into Int64...")
                return nil
            }
            
            return id
        } catch {
            print("Error getting last ID in CDClient... \(error)")
            
            return nil
        }
    }
    
    static func appendEssay(prompt: String, essayText: String, date: Date, userEdited: Bool) async throws -> Essay? {
        // Get lastID if it exists, otherwise set to 0
        let id = await getLastEssayID() ?? 0
        
        // Insert new Essay and set values
        guard let essay = try await CDClient.buildAndSave(
            named: essayEntityName,
            builder: {mo in
                guard let essay = mo as? Essay else {
                    return
                }
                
                essay.id = id
                essay.prompt = prompt
                essay.essay = essayText
                essay.date = date
                essay.userEdited = userEdited
            }) as? Essay else {
            return nil
        }
        
        return essay
    }
    
    static func deleteEssay(_ essay: inout Essay) async throws {
        try await CDClient.delete(managedObjectID: essay.objectID)
    }
    
    static func getAllEssaysReversed() async -> [Essay]? {
        do {
            return try await (CDClient.getAll(in: essayEntityName) as? [Essay])?.reversed()
        } catch {
            print("Error getting all Essays... \(error)")
            
            return nil
        }
    }
    
    static func updateEssay(_ essay: inout Essay, withText text: String) async throws {
        // Update essay
        guard let essayNewContext = try await CDClient.update(
            managedObjectID: essay.objectID,
            updater: {mo in
                guard let essay = mo as? Essay else {
                    return
                }
                
                essay.essay = text
            }) as? Essay else {
            return
        }
        
        // Set essay to essay new context
        essay = essayNewContext
    }
}
