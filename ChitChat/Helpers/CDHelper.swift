//
//  CDHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/21/23.
//

import CoreData
import Foundation

class CDHelper {
    
    static func getLastID() -> Int64 {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return -1 }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.coreDataEssayEntityName)
        
        do {
            let fetched = try managedContext.fetch(fetchRequest)
            guard let id = fetched[fetched.count - 1].value(forKey: Constants.coreDataEssayIDObjectName) as? Int64 else {
                print("Error converting ID into Int64...")
                return -1
            }
            
            return id
        } catch let error as NSError {
            print("Error getting last ID... \(error), \(error.userInfo)")
        }
        
        return -1
    }
    
    static func appendEssay(prompt: String, essay: String, date: Date, userEdited: Bool, essayArray: inout [NSManagedObject], success: @escaping() -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: Constants.coreDataEssayEntityName, in: managedContext)!
        let essayObject = NSManagedObject(entity: entity, insertInto: managedContext)
        
        let lastID = getLastID()
        
        if lastID == -1 {
            print("Issue getting the last ID...")
            return
        }
        
        essayObject.setValue(lastID, forKey: Constants.coreDataEssayIDObjectName)
        essayObject.setValue(prompt, forKey: Constants.coreDataEssayPromptObjectName)
        essayObject.setValue(essay, forKey: Constants.coreDataEssayEssayObjectName)
        essayObject.setValue(date, forKey: Constants.coreDataEssayDateObjectName)
        essayObject.setValue(userEdited, forKey: Constants.coreDataEssayUserEditedObjectName)
        
        do {
            try managedContext.save()
            essayArray.append(essayObject) // Append object to essayArray once the managed context is successfully saved
            success()
        } catch let error as NSError {
            print("Error saving Essay... \(error), \(error.userInfo)")
        }
    }
    
    static func getAllEssays(essayArray: inout [NSManagedObject]) {
        //TODO: - Should this asynchronously load instead of preloading all of them?
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.coreDataEssayEntityName)
        
        do {
            essayArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error fetching Essay... \(error), \(error.userInfo)")
        }
    }
    
    static func deleteEssay(id: Int, essayArray: inout [NSManagedObject], success: @escaping() -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.coreDataEssayEntityName)
        fetchRequest.predicate = NSPredicate(format: "id = \(id)")
        
        do {
            let fetched = try managedContext.fetch(fetchRequest)
            
            guard let essayToDelete = fetched.last else {
                print("Could not get the essayToDelete...")
                return
            }
            
            guard let index = essayArray.firstIndex(of: essayToDelete) else {
                print("Essay from managedContext not in Essay array...")
                return
            }
            
            managedContext.delete(essayToDelete)
            
            do {
                try managedContext.save()
                essayArray.remove(at: index) // Remove the object from Essays once the managed context is successfully saved
                success()
            } catch {
                print("Error saving deleted essay... ")
            }
        } catch let error as NSError {
            print("Error fetching essay to delete... \(error), \(error.userInfo)")
        }
    }
    
    static func updateEssay(id: Int, newEssay: String, userEdited: Bool, essayArray: inout [NSManagedObject]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.coreDataEssayEntityName)
        fetchRequest.predicate = NSPredicate(format: "id = \(id)")
        
        do {
            let fetched = try managedContext.fetch(fetchRequest)
            let objectToUpdate = fetched.last!
            
            objectToUpdate.setValue(newEssay, forKey: Constants.coreDataEssayEssayObjectName)
            objectToUpdate.setValue(userEdited, forKey: Constants.coreDataEssayUserEditedObjectName)
            
            do {
                try managedContext.save()
            } catch {
                print("Error saving updated essay... \(error)")
            }
        } catch let error as NSError {
            print("Error updating Essay... \(error), \(error.userInfo)")
        }
    }
}
