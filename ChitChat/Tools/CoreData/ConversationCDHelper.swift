//
//  ConversationCDHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/18/23.
//

import CoreData
import Foundation

class ConversationCDHelper: Any {
    
    static let conversationEntityName = String(describing: Conversation.self)
    
    static func appendConversation() async throws -> NSManagedObjectID? {
        return try await appendConversation(conversationID: Int64(Constants.defaultConversationID))
    }
    
    static func appendConversation(conversationID: Int64) async throws -> NSManagedObjectID? {
        return try await appendConversation(conversationID: conversationID, behavior: nil)
    }
    
    static func appendConversation(conversationID: Int64, behavior: String?) async throws -> NSManagedObjectID? {
        // Could also do it this way, but I think the way I have it now is cooler!
//            let keyValueMap: Dictionary<String, Any> = [
//                #keyPath(Conversation.conversationID):conversationID,
//                #keyPath(Conversation.behavior):behavior!
//            ]
        
//            return try CDClient.append(keyValueMap: keyValueMap, in: conversationEntityName) as! Conversation
        
        // Unwrap, build and save conversation and return, otherwise return nil
        try await CDClient.buildAndSave(
            named: conversationEntityName,
            builder: {mo in
                guard let conversation = mo as? Conversation else {
                    return
                }
                
                conversation.conversationID = conversationID
                conversation.behavior = behavior
            })
    }
    
//    static func convertToPermanentID(_ conversation: Conversation) async throws {
//        try await CDClient.convertToPermanentID(managedObject: conversation)
//    }
    
    static func getConversationObjectIDBy(idURL: URL) async -> NSManagedObjectID? {
        await CDClient.getObjectID(managedObjectIDURLRepresentation: idURL)
    }
    
    static func getConversationBy(conversationID: Int64) async -> Conversation? {
        do {
            let conversations = try await CDClient.getAll(in: conversationEntityName, where: [#keyPath(Conversation.conversationID): conversationID]) as! [Conversation]

            if conversations.count == 0 {
                print("No conversations for conversationID")
                return nil
            }

            if conversations.count > 1 {
                print("More than one conversation for conversationID")
            }

            return conversations[0]
        } catch {
            print("Error getting conversations by conversationID")

            return nil
        }
    }
    
    static func getConversationID(conversationObjectID: NSManagedObjectID) async throws -> Int64? {
        (try await CDClient.get(managedObjectID: conversationObjectID) as? Conversation)?.conversationID
    }
    
    static func getAllConversations() async -> [Conversation]? {
        do {
            return try await CDClient.getAll(in: conversationEntityName) as? [Conversation]
        } catch {
            print("Error getting all Conversations... \(error)")
            
            return nil
        }
    }
    
    static func deleteConversation(conversationObjectID: NSManagedObjectID) async throws {
        try await CDClient.delete(managedObjectID: conversationObjectID)
    }
    
    static func isValidObject(conversationObjectID: NSManagedObjectID?) async -> Bool {
        guard let conversationObjectID = conversationObjectID else {
            return false
        }
        
        var isValid = true
        
        do {
            try await CDClient.get(managedObjectID: conversationObjectID)
        } catch {
            if let error = error as? NSError {
                // TODO: Should I just use the isValid here, or should I just always set isValid to false if it errors?
                isValid = error.code != NSManagedObjectReferentialIntegrityError
            }
        }
        
        return isValid
    }
    
    static func updateConversation(conversationObjectID: NSManagedObjectID, withConversationID conversationID: Int64) async throws {
        // Update using CDClient
        try await CDClient.update(managedObjectID: conversationObjectID) {mo in
            guard let conversation = mo as? Conversation else {
                return
            }
            
            conversation.conversationID = conversationID
        }
    }
    
    static func updateConversation(conversationObjectID: NSManagedObjectID, withLatestChatDate latestChatDate: Date) async throws {
        // Update using CDClient
        try await CDClient.update(managedObjectID: conversationObjectID) {mo in
            guard let conversation = mo as? Conversation else {
                return
            }

            conversation.latestChatDate = latestChatDate
        }
    }

    static func updateConversation(conversationObjectID: NSManagedObjectID, withLatestChatText latestChatText: String) async throws {
        // Update using CDClient
        try await CDClient.update(managedObjectID: conversationObjectID) {mo in
            guard let conversation = mo as? Conversation else {
                return
            }

            conversation.latestChatText = latestChatText
        }
    }
    
    static func sync(_ conversation: inout Conversation) async throws {
        guard let conversationNewContext = try await CDClient.get(managedObjectID: conversation.objectID) as? Conversation else {
            return
        }
        
        conversation = conversationNewContext
    }
    
}
