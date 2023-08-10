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
    
    static func appendConversation() async throws -> Conversation? {
        return try await appendConversation(conversationID: Int64(Constants.defaultConversationID))
    }
    
    static func appendConversation(conversationID: Int64) async throws -> Conversation? {
        return try await appendConversation(conversationID: conversationID, behavior: nil)
    }
    
    static func appendConversation(conversationID: Int64, behavior: String?) async throws -> Conversation? {
        // Could also do it this way, but I think the way I have it now is cooler!
//            let keyValueMap: Dictionary<String, Any> = [
//                #keyPath(Conversation.conversationID):conversationID,
//                #keyPath(Conversation.behavior):behavior!
//            ]
        
//            return try CDClient.append(keyValueMap: keyValueMap, in: conversationEntityName) as! Conversation
        
        // Unwrap, build and save conversation and return, otherwise return nil
        guard let conversation = try await CDClient.buildAndSave(
            named: conversationEntityName,
            builder: {mo in
                guard let conversation = mo as? Conversation else {
                    return
                }
                
                conversation.conversationID = conversationID
                conversation.behavior = behavior
            }) as? Conversation else {
            return nil
        }
        
        return conversation
    }
    
    static func convertToPermanentID(_ conversation: Conversation) async throws {
        try await CDClient.convertToPermanentID(managedObject: conversation)
    }
    
    static func getConversationBy(idURL: URL) async -> Conversation? {
        do {
            return try await CDClient.get(managedObjectIDURLRepresentation: idURL) as? Conversation
        } catch {
            print("Error getting conversation by idURL... \(error)")
            
            return nil
        }
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
    
    static func getAllConversations() async -> [Conversation]? {
        do {
            return try await CDClient.getAll(in: conversationEntityName) as? [Conversation]
        } catch {
            print("Error getting all Conversations... \(error)")
            
            return nil
        }
    }
    
    static func deleteConversation(_ conversation: Conversation) async throws {
        try await CDClient.delete(managedObjectID: conversation.objectID)
    }
    
    static func updateConversation(_ conversation: inout Conversation, withConversationID conversationID: Int64) async throws {
        // Update using CDClient
        guard let conversationNewContext = try await CDClient.update(
            managedObjectID: conversation.objectID,
            updater: {mo in
                guard let conversation = mo as? Conversation else {
                    return
                }
                
                conversation.conversationID = conversationID
            }) as? Conversation else {
                return
            }
        
        conversation = conversationNewContext
    }
    
    static func sync(_ conversation: inout Conversation) async throws {
        guard let conversationNewContext = try await CDClient.get(managedObjectID: conversation.objectID) as? Conversation else {
            return
        }
        
        conversation = conversationNewContext
    }
    
}
