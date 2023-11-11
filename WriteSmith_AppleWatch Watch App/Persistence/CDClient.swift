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
    
    public static let mainManagedObjectContext: NSManagedObjectContext = persistentContainer.viewContext
//    private static let backgroundManagedObjectContext: NSManagedObjectContext = {
//        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        managedObjectContext.parent = mainManagedObjectContext
//        return managedObjectContext
//    }()
    
//    internal static func append(keyValueMap: Dictionary<String, Any>, in entityName: String) async throws {
//        try await backgroundManagedObjectContext.perform {
//            // Get entity
//            let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: backgroundManagedObjectContext)
//
//            // Set keyValueMap entries as entity values
//            keyValueMap.forEach({ key, value in
//                entity.setValue(value, forKey: key)
//            })
//
//            // Save context, obtain permanent ID, and return object ID
//            try backgroundManagedObjectContext.save()
//
//            try mainManagedObjectContext.performAndWait {
//                try mainManagedObjectContext.save()
//            }
//        }
//    }
    
//    internal static func buildAndSave(named entityName: String, builder: @escaping (NSManagedObject)->Void) async throws -> NSManagedObjectID {
//        return try await mainManagedObjectContext.perform {
//            // Insert managed object
//            let managedObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: mainManagedObjectContext)
//
//            // Do builder
//            builder(managedObject)
//
//            // Save context and return object ID
//            try mainManagedObjectContext.save()
//
//            return managedObject.objectID
//        }
//    }
    
//    internal static func buildAndSaveToParent(named entityName: String, to parentFetchRequest: NSFetchRequest<NSManagedObject>, builder: @escaping (_ child: NSManagedObject, _ parents: [NSManagedObject])->Void) async throws {
//        try await backgroundManagedObjectContext.perform {
//            // Get parent managed objects
//            let parentManagedObjects = try backgroundManagedObjectContext.fetch(parentFetchRequest)
//
//            // Insert child managed object
//            let childManagedObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: backgroundManagedObjectContext)
//
//            // Do builder
//            builder(childManagedObject, parentManagedObjects)
//
//            // Save context and return object ID
//            try backgroundManagedObjectContext.save()
//
//            try mainManagedObjectContext.performAndWait {
//                try mainManagedObjectContext.save()
//            }
//        }
//    }
    
//    internal static func buildAndSaveToParent(named entityName: String, to parentID: NSManagedObjectID, builder: @escaping (_ child: NSManagedObject, _ parent: NSManagedObject)->Void) async throws {
//        try await mainManagedObjectContext.perform {
//            // Get parent managed object
//            let parentManagedObject = try mainManagedObjectContext.existingObject(with: parentID)
//
//            // Insert child managed object
//            let childManagedObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: mainManagedObjectContext)
//
//            // Do builder
//            builder(childManagedObject, parentManagedObject)
//
//            // Save context and return object ID
//            try mainManagedObjectContext.save()
//        }
//    }
//
//    internal static func count<O: NSManagedObject>(fetchRequest: NSFetchRequest<O>) async throws -> Int {
//        return try await mainManagedObjectContext.perform {
//            // Get count and return
//            let count = try mainManagedObjectContext.count(for: fetchRequest)
//
//            return count
//        }
//    }
//
//    internal static func count(entityName: String) async throws -> Int {
//        return try await mainManagedObjectContext.perform {
//            // Create fetch request
//            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
//
//            // Get count and return
//            let count = try mainManagedObjectContext.count(for: fetchRequest)
//
//            return count
//        }
//    }
//
//    internal static func doInContext<T>(managedObjectID: NSManagedObjectID, block: @escaping (NSManagedObject)->T?) async throws -> T? {
//        return try await mainManagedObjectContext.perform {
//            let managedObject = try mainManagedObjectContext.existingObject(with: managedObjectID)
//
//            return block(managedObject)
//        }
//    }
    
//    internal static func getAll(in entityName: String) async throws -> [NSManagedObject] {
//        return try await getAll(in: entityName, where: nil)
//    }
//
//    internal static func getAll(in entityName: String, where whereColValMap: Dictionary<String, CVarArg>?) async throws -> [NSManagedObject] {
//        return try await getAll(in: entityName, where: whereColValMap, sortDescriptors: nil)
//    }
//
//    internal static func getAll(in entityName: String, sortDescriptors: [NSSortDescriptor]?) async throws -> [NSManagedObject] {
//        return try await getAll(in: entityName, where: nil, sortDescriptors: sortDescriptors)
//    }
//
//    internal static func getAll(in entityName: String, where whereColValMap: [String: CVarArg]?, sortDescriptors: [NSSortDescriptor]?) async throws -> [NSManagedObject] {
//        return try await backgroundManagedObjectContext.perform {
//            // Create fetch request
//            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
//
//            // Ensure objects are not returned as faults TODO: Is this good practice? Returning faults helps code efficienty.. what about when the database gets large?
//            fetchRequest.returnsObjectsAsFaults = false
//
//            // Set sortDescriptor if there is one
//            if sortDescriptors != nil {
//                fetchRequest.sortDescriptors = sortDescriptors
//            }
//
//            // Append and set predicate if whereColValMap can be unwrapped
//            if let whereColValMap = whereColValMap {
//                fetchRequest.predicate = parsePredicateFromWhereColValMap(whereColValMap: whereColValMap)
//            }
//
//            return try backgroundManagedObjectContext.fetch(fetchRequest)
//        }
//    }
//
//    internal static func get(managedObjectID: NSManagedObjectID) async throws -> NSManagedObject {
//        try await backgroundManagedObjectContext.perform {
//            try backgroundManagedObjectContext.existingObject(with: managedObjectID)
//        }
//    }
//
//    internal static func getObjectID(managedObjectIDURLRepresentation urlRepresentation: URL) async -> NSManagedObjectID? {
//        await backgroundManagedObjectContext.perform {
//            backgroundManagedObjectContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: urlRepresentation)
//        }
//    }
    
//    internal static func convertToPermanentID(managedObject: NSManagedObject) async throws {
//        try await backgroundManagedObjectContext.perform {
//            // Obtain the permanent ID for managedObject if it is temporary
//            if managedObject.objectID.isTemporaryID {
//                try backgroundManagedObjectContext.obtainPermanentIDs(for: [managedObject])
//            }
//
////             //Return objectID
////            return managedObject
//        }
//    }
    
//    internal static func getPermanentIDs(_ fetchRequest: NSFetchRequest<NSManagedObject>) async throws -> [NSManagedObjectID] {
//        try await mainManagedObjectContext.perform {
//            // Perform fetchRequest
//            let managedObjects = try mainManagedObjectContext.fetch(fetchRequest)
//
//            // Obtain permanent IDs for all managedObjects
//            try mainManagedObjectContext.obtainPermanentIDs(for: managedObjects)
//
//            // Return managedObjects mapped to array of their objectIDs
//            return managedObjects.map({$0.objectID})
//        }
//    }
//
//    internal static func delete(fetchRequest: NSFetchRequest<NSManagedObject>) async throws {
//        return try await mainManagedObjectContext.perform {
//            // Get managedObjects using fetchRequest on backgroundManagedObjectContext
//            let managedObjects = try mainManagedObjectContext.fetch(fetchRequest)
//
//            // Do deletion all managedObjects
//            for managedObject in managedObjects {
//                mainManagedObjectContext.delete(managedObject)
//            }
//
//            // Save context
//            try mainManagedObjectContext.save()
//        }
//    }
//
//    internal static func delete(managedObjectID: NSManagedObjectID) async throws {
//        return try await mainManagedObjectContext.perform {
//            // Get managedObject by id TODO: Is it okay to just use the object instead of existingObject here since it's deleting anyways? Or does it not even matter because it can throw?
//            let managedObject = mainManagedObjectContext.object(with: managedObjectID)
//
//            // Delete in managed context
//            mainManagedObjectContext.delete(managedObject)
//
//            // Save context and return so that it can be checked for deletion :)
//            try mainManagedObjectContext.save()
//        }
//    }
    
//    internal static func update(fetchRequest: NSFetchRequest<NSManagedObject>, updater: @escaping ([NSManagedObject])->Void) async throws {
//        try await backgroundManagedObjectContext.perform {
//            // Get managedObjects using fetchRequest on backgroundManagedObjectContext
//            let managedObjects = try backgroundManagedObjectContext.fetch(fetchRequest)
//
//            // Do updater
//            updater(managedObjects)
//
//            // Save context
//            try backgroundManagedObjectContext.save()
//
//            return try mainManagedObjectContext.performAndWait {
//                try mainManagedObjectContext.save()
//            }
//        }
//    }
    
//    internal static func update(managedObjectID: NSManagedObjectID, updater: @escaping (NSManagedObject)->Void) async throws {
//        try await mainManagedObjectContext.perform {
//            // Get managedObject as existing object with managedObjectID
//            let managedObject = try mainManagedObjectContext.existingObject(with: managedObjectID)
//
//            // Do updater
//            updater(managedObject)
//
//            // Save context
//            try mainManagedObjectContext.save()
//        }
//    }
//
//    private static func parsePredicateFromWhereColValMap(whereColValMap: [String: CVarArg]) -> NSPredicate {
//        // Create predicate array
//        var predicates: [NSPredicate] = []
//
//        // Append to predicates
//        whereColValMap.forEach({ key, value in
//            predicates.append(NSPredicate(format: "%@ = %@", key, value))
//
//            // If value is a string, add quotes, otherwise just keep as value
////            if value is String {
//                //predicateString += "\(key) = \"\(value)\"\(predicateDivider)"
////                predicateString += String(format: "%@ = %@%@", key, value, predicateDivider)
////            } else {
////                //predicateString += "\(key) = \(value)\(predicateDivider)"
////                predicateString += String(format: "%@ = %@%@", key, value, predicateDivider)
////            }
//        })
//
////        // Remove last predicate divider from predicate if it is long enough to do so
////        if predicateString.count >= predicateDivider.count {
////            predicateString.removeLast(predicateDivider.count)
////        }
//
//        // Return NSCompoundPredicate with the predicates in the array
//        return NSCompoundPredicate(type: .and, subpredicates: predicates)
//    }
    
    
}

