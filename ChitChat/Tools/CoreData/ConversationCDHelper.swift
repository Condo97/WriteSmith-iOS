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
    
    static func appendConversation() -> Conversation? {
        return appendConversation(conversationID: -1)
    }
    
    static func appendConversation(conversationID: Int64) -> Conversation? {
        return appendConversation(conversationID: conversationID, behavior: nil)
    }
    
    static func appendConversation(conversationID: Int64, behavior: String?) -> Conversation? {
        do {
            // Could also do it this way, but I think the way I have it now is cooler!
//            let keyValueMap: Dictionary<String, Any> = [
//                #keyPath(Conversation.conversationID):conversationID,
//                #keyPath(Conversation.behavior):behavior!
//            ]
            
//            return try CDClient.append(keyValueMap: keyValueMap, in: conversationEntityName) as! Conversation

            let conversation = try CDClient.insert(named: conversationEntityName) as! Conversation

            conversation.conversationID = conversationID
            conversation.behavior = behavior

            do {
                try CDClient.saveContext()

                return conversation
            } catch {
                print("Error saving context when appending Conversation... \(error)")

                return nil
            }
        } catch {
            print("Error inserting Conversation... \(error)")
            
            return nil
        }
    }
    
    static func getConversationBy(idURL: URL) -> Conversation? {
        do {
            return try CDClient.getByIDURL(idURL, in: conversationEntityName) as? Conversation
        } catch {
            print("Error getting conversation by idURL")
            
            return nil
        }
    }
    
    static func getConversationBy(conversationID: Int64) -> Conversation? {
        do {
            let conversations = try CDClient.getAll(in: conversationEntityName, where: [#keyPath(Conversation.conversationID): conversationID]) as! [Conversation]
            
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
    
    static func getAllConversations() -> [Conversation]? {
        do {
            return try CDClient.getAll(in: conversationEntityName) as? [Conversation]
        } catch {
            print("Error getting all Conversations... \(error)")
            
            return nil
        }
    }
    
    @discardableResult
    static func deleteConversation(_ conversation: Conversation) -> Bool {
        do {
            try CDClient.delete(conversation)
            
            return true
        } catch {
            print("Error deleting Conversation... \(error)")
            
            return false
        }
    }
    
    @discardableResult
    static func saveContext() -> Bool {
        do {
            try CDClient.saveContext()
            
            return true
        } catch {
            print("Error saving Conversation... \(error)")
            
            return false
        }
    }
    
}
