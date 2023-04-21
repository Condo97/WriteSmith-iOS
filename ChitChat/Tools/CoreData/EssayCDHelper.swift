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
    
    static func getLastEssayID() -> Int64? {
        do {
            //TODO: Add predicate to only get the latest object
            let essays = try CDClient.getAll(in: essayEntityName)
            
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
    
    static func appendEssay(prompt: String, essayText: String, date: Date, userEdited: Bool) -> Essay? {
        // Get lastID if it exists, otherwise set to 0
        let id = getLastEssayID() ?? 0
        
        // Insert new Essay and set values
        do {
            let essay = try CDClient.insert(named: essayEntityName) as! Essay
            
            essay.id = id
            essay.prompt = prompt
            essay.essay = essayText
            essay.date = date
            essay.userEdited = userEdited
            
            do {
                try CDClient.saveContext()
                
                return essay
            } catch {
                print("Error saving context when appending Essay... \(error)")
                
                return nil
            }
        } catch {
            print("Error inserting new Essay object... \(error)")
            
            return nil
        }
    }
    
    static func getAllEssaysReversed() -> [Essay]? {
        do {
            return try (CDClient.getAll(in: essayEntityName) as? [Essay])?.reversed()
        } catch {
            print("Error getting all Essays... \(error)")
            
            return nil
        }
    }
    
    static func deleteEssay(_ essay: Essay) -> Bool {
        do {
            try CDClient.delete(essay)
            
            return true
        } catch {
            print("Error deleting Essay... \(error)")
            
            return false
        }
    }
    
    static func saveContext() -> Bool {
        do {
            try CDClient.saveContext()
            
            return true
        } catch {
            print("Error saving Essay... \(error)")
            
            return false
        }
    }
}
