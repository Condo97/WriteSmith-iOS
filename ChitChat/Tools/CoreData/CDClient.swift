//
//  CDClient.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/18/23.
//

import CoreData
import Foundation
import UIKit

class CDClient: Any {
    
    internal static let modelName: String = Constants.Additional.coreDataModelName
    
//    internal static var appDelegate: AppDelegate {
//        get {
//            if Thread.isMainThread {
//                return UIApplication.shared.delegate as! AppDelegate
//            } else {
//                var appDelegate: AppDelegate? = nil
//                DispatchQueue.main.sync {
//                    appDelegate = UIApplication.shared.delegate as? AppDelegate
//                }
//                return appDelegate!
//            }
//        }
//    }
    private static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores(completionHandler: {description, error in
            if let error = error as? NSError {
                fatalError("Couldn't load persistent stores!\n\(error)\n\(error.userInfo)")
            }
        })
        return container
    }()
    
    private static let mainManagedObjectContext: NSManagedObjectContext = persistentContainer.viewContext
    private static let backgroundManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = mainManagedObjectContext
        return managedObjectContext
    }()
    
    internal static func append(keyValueMap: Dictionary<String, Any>, in entityName: String) async throws -> NSManagedObject {
        try await backgroundManagedObjectContext.perform {
            // Get entity
            let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: backgroundManagedObjectContext)
            
            // Set keyValueMap entries as entity values
            keyValueMap.forEach({ key, value in
                entity.setValue(value, forKey: key)
            })
            
            // Save context and return entity
            try backgroundManagedObjectContext.save()
            
            return try mainManagedObjectContext.performAndWait {
                try mainManagedObjectContext.save()
                
                return entity
            }
        }
    }
    
    internal static func buildAndSave(named entityName: String, builder: @escaping (NSManagedObject)->Void) async throws -> NSManagedObject {
        return try await backgroundManagedObjectContext.perform {
            // Set managed object
            let managedObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: backgroundManagedObjectContext)
            
            // Do builder
            builder(managedObject)
            
            // Save context and return entity
            try backgroundManagedObjectContext.save()
            
            return try mainManagedObjectContext.performAndWait {
                try mainManagedObjectContext.save()
                
                return managedObject
            }
        }
    }
    
    internal static func buildAndSaveToParent(named entityName: String, to parentID: NSManagedObjectID, builder: @escaping (_ child: NSManagedObject, _ parent: NSManagedObject)->Void) async throws -> (NSManagedObject, NSManagedObject) {
        return try await backgroundManagedObjectContext.perform {
            // Get parent managed object
            let parentManagedObject = try backgroundManagedObjectContext.existingObject(with: parentID)
            
            // Set child managed object
            let childManagedObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: backgroundManagedObjectContext)
            
            // Do builder
            builder(childManagedObject, parentManagedObject)
            
            // Save context and return entity
            try backgroundManagedObjectContext.save()
            
            return try mainManagedObjectContext.performAndWait {
                try mainManagedObjectContext.save()
                
                return (childManagedObject, parentManagedObject)
            }
        }
    }
    
    internal static func count(entityName: String) async throws -> Int {
        return try await backgroundManagedObjectContext.perform {
            // Create fetch request
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            
            // Get count
            let count = try backgroundManagedObjectContext.count(for: fetchRequest)
            
            return count
        }
    }
    
    internal static func doInContext(managedObjectID: NSManagedObjectID, block: @escaping (NSManagedObject)->Void) async throws {
        return try await backgroundManagedObjectContext.perform {
            let managedObject = try backgroundManagedObjectContext.existingObject(with: managedObjectID)
            
            block(managedObject)
        }
    }
    
    internal static func getAll(in entityName: String) async throws -> [NSManagedObject] {
        return try await getAll(in: entityName, where: nil)
    }
    
    internal static func getAll(in entityName: String, where whereColValMap: Dictionary<String, Any>?) async throws -> [NSManagedObject] {
        return try await getAll(in: entityName, where: whereColValMap, sortDescriptors: nil)
    }
    
    internal static func getAll(in entityName: String, sortDescriptors: [NSSortDescriptor]?) async throws -> [NSManagedObject] {
        return try await getAll(in: entityName, where: nil, sortDescriptors: sortDescriptors)
    }
    
    internal static func getAll(in entityName: String, where whereColValMap: [String: Any]?, sortDescriptors: [NSSortDescriptor]?) async throws -> [NSManagedObject] {
        return try await backgroundManagedObjectContext.perform {
            // Create fetch request
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            
            // Set sortDescriptor if there is one
            if sortDescriptors != nil {
                fetchRequest.sortDescriptors = sortDescriptors
            }
            
            // Append and set predicate if whereColValMap can be unwrapped
            if let whereColValMap = whereColValMap {
                fetchRequest.predicate = parsePredicateFromWhereColValMap(whereColValMap: whereColValMap)
            }
            
            return try backgroundManagedObjectContext.fetch(fetchRequest)
        }
    }
    
    internal static func get(managedObjectID: NSManagedObjectID) async throws -> NSManagedObject {
        try await backgroundManagedObjectContext.perform {
            try backgroundManagedObjectContext.existingObject(with: managedObjectID)
        }
    }
    
    internal static func get(managedObjectIDURLRepresentation urlRepresentation: URL) async throws -> NSManagedObject? {
        try await backgroundManagedObjectContext.perform {
            guard let managedObjectID = backgroundManagedObjectContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: urlRepresentation) else {
                return nil
            }
            
            return try backgroundManagedObjectContext.existingObject(with: managedObjectID)
        }
    }
    
    internal static func convertToPermanentID(managedObject: NSManagedObject) async throws {
        try await backgroundManagedObjectContext.perform {
            // Obtain the permanent ID for managedObject if it is temporary
            if managedObject.objectID.isTemporaryID {
                try backgroundManagedObjectContext.obtainPermanentIDs(for: [managedObject])
            }
            
//             //Return objectID
//            return managedObject
        }
    }
    
    @discardableResult
    internal static func delete(managedObjectID: NSManagedObjectID) async throws -> NSManagedObject {
        return try await backgroundManagedObjectContext.perform {
            // Get managedObject by id TODO: Is it okay to just use the object instead of existingObject here since it's deleting anyways? Or does it not even matter because it can throw?
            let managedObject = backgroundManagedObjectContext.object(with: managedObjectID)
            
            // Delete in managed context
            backgroundManagedObjectContext.delete(managedObject)
            
            // Save context and return so that it can be checked for deletion :)
            try backgroundManagedObjectContext.save()
            
            return try mainManagedObjectContext.performAndWait {
                try mainManagedObjectContext.save()
                
                return managedObject
            }
        }
    }
    
    internal static func update(managedObjectID: NSManagedObjectID, updater: @escaping (NSManagedObject)->Void) async throws -> NSManagedObject {
        try await backgroundManagedObjectContext.perform {
            // Get managedObject as existing object with managedObjectID
            let managedObject = try backgroundManagedObjectContext.existingObject(with: managedObjectID)
            
            // Do updater
            updater(managedObject)
            
            // Save context
            try backgroundManagedObjectContext.save()
            
            return try mainManagedObjectContext.performAndWait {
                try mainManagedObjectContext.save()
                
                return managedObject
            }
        }
    }
    
    private static func parsePredicateFromWhereColValMap(whereColValMap: [String: Any]) -> NSPredicate {
        // Create predicate
        let predicateDivider = ", "
        var predicateString = ""
        
        // Append to predicate
        whereColValMap.forEach({ key, value in
            // If value is a string, add quotes, otherwise just keep as value
            if value is String {
                predicateString += "\(key) = \"\(value)\"\(predicateDivider)"
            } else {
                predicateString += "\(key) = \(value)\(predicateDivider)"
            }
        })
        
        // Remove last predicate divider from predicate if it is long enough to do so
        if predicateString.count >= predicateDivider.count {
            predicateString.removeLast(predicateDivider.count)
        }
        
        // Return predicate
        return NSPredicate(format: predicateString)
    }
    
    
}
