//
//  CDClient.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/18/23.
//

import CoreData
import Foundation

class CDClient: Any {
    
    static func getAppDelegateOnMainThread() -> AppDelegate {
        // If the current thread is the main thread, then return the shared delegate
        if Thread.isMainThread {
            return UIApplication.shared.delegate as! AppDelegate
        }
        
        // Otherwise, get and return the shared delegate from the main thread
        let dispatchGroup = DispatchGroup()
        var appDelegate: AppDelegate?
        
        dispatchGroup.enter()
        DispatchQueue.main.async {
            appDelegate = UIApplication.shared.delegate as? AppDelegate
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        
        return appDelegate!
    }
    
    static func insert(named entityName: String) throws -> NSManagedObject {
        //TODO: AppDelegate needs to be called on main thread, is there a better way to do this?
        // Get AppDelegate on main thread
        let appDelegate = getAppDelegateOnMainThread()
        
        // Set managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Set managed object
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedContext)
        
        // Save context and return managed object
        try saveContext()
        
        return managedObject
    }
    
    static func append(keyValueMap: Dictionary<String, Any>, in entityName: String) throws -> NSManagedObject {
        // Get AppDelegate on main thread
        let appDelegate = getAppDelegateOnMainThread()
        
        // Get managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Get entity
        let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedContext)
        
        // Set keyValueMap entries as entity values
        keyValueMap.forEach({ key, value in
            entity.setValue(value, forKey: key)
        })
        
        // Save context and return entity
        try saveContext()
        
        return entity
    }
    
    static func getByIDURL(_ idURL: URL, in entityName: String) throws -> NSManagedObject? {
        // Get AppDelegate on main thread
        let appDelegate = getAppDelegateOnMainThread()
        
        // Get managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Get managed object ID from idURL or return nil
        guard let managedObjectID = managedContext.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: idURL) else {
            print("Error getting objectID from idURL")
            return nil
        }
        
        // Return object
        return try managedContext.existingObject(with: managedObjectID)
    }
    
    static func getAll(in entityName: String) throws -> [NSManagedObject] {
        return try getAll(in: entityName, where: nil)
    }
    
    static func getAll(in entityName: String, where whereColValMap: Dictionary<String, Any>?) throws -> [NSManagedObject] {
        return try getAll(in: entityName, where: whereColValMap, sortDescriptors: nil)
    }
    
    static func getAll(in entityName: String, sortDescriptors: [NSSortDescriptor]?) throws -> [NSManagedObject] {
        return try getAll(in: entityName, where: nil, sortDescriptors: sortDescriptors)
    }
    
    static func getAll(in entityName: String, where whereColValMap: Dictionary<String, Any>?, sortDescriptors: [NSSortDescriptor]?) throws -> [NSManagedObject] {
        // Get AppDelegate on main thread
        let appDelegate = getAppDelegateOnMainThread()
        
        // Get managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        // Set sortDescriptor if there is one
        if sortDescriptors != nil {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        // Append and set predicate if whereColValMap is not nil
        if whereColValMap != nil {
            // Create predicate
            let predicateDivider = ", "
            var predicateString = ""
            
            // Append to predicate
            whereColValMap!.forEach({ key, value in
                predicateString += "\(key) = \(value)\(predicateDivider)"
            })
            
            // Remove last predicate divider from predicate if it is long enough to do so
            if predicateString.count >= predicateDivider.count {
                predicateString.removeLast(predicateDivider.count)
            }
            
            // Create and use preidcate
            fetchRequest.predicate = NSPredicate(format: predicateString)
        }
        
        return try managedContext.fetch(fetchRequest)
    }
    
    static func delete(_ managedObject: NSManagedObject) throws {
        // Get AppDelegate on main thread
        let appDelegate = getAppDelegateOnMainThread()
        
        // Get managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Delete in managed context
        managedContext.delete(managedObject)
        
        // Save context
        try saveContext()
    }
    
    static func saveContext() throws {
        // Get AppDelegate on main thread
        let appDelegate = getAppDelegateOnMainThread()
        
        // Get managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Save context
        try managedContext.save()
    }
    
}
