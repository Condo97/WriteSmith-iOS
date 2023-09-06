//
//  ChatCDHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/18/23.
//

import CoreData
import Foundation

class ChatCDHelper {
    
    static let chatEntityName = String(describing: Chat.self)
    
    static func appendChat(sender: String, text: String, to conversationObjectID: NSManagedObjectID) async throws -> NSManagedObjectID {
        // Build and save new chat to parent conversation
        try await CDClient.buildAndSaveToParent(
            named: chatEntityName,
            to: conversationObjectID,
            builder: {cmo, pmo in
                guard let chat = cmo as? Chat, let conversation = pmo as? Conversation else {
                    return
                }
                
                // Get current date for chat and conversation
                let date = Date()
                
                // Update chat values
                chat.sender = sender
                chat.text = text
                chat.date = date
                chat.conversation = conversation
                
                // Update conversation latestChatDate and latestChatText TODO: Is this appropriate to do here? I guess this is the best place lol
                conversation.latestChatDate = date
                conversation.latestChatText = text
            })
    }
    
    static func deleteChat(chatObjectID: NSManagedObjectID) async throws {
        try await CDClient.delete(managedObjectID: chatObjectID)
    }
    
    static func getOrderedChatArray(conversationObjectID: NSManagedObjectID) async throws -> [Chat]? {
//        // Sync conversation
//        try await ConversationCDHelper.sync(&conversation)
//        guard let chats = try await CDClient.getAll(in: chatEntityName, where: [#keyPath(Chat.conversation): conversation], sortDescriptors: [NSSortDescriptor(key: #keyPath(Chat.date), ascending: true)]) as? [Chat] else {
//            return nil
//        }
//
//        return chats;
        
        // Create date sorted array from conversation chats
//        conversation.willAccessValue(forKey: chatEntityName)
//        print(conversation.isFault)
//        print(conversation.chats)
        guard let chats = try await CDClient.getAll(
            in: chatEntityName,
            where: [#keyPath(Chat.conversation): conversationObjectID]
        ) as? [Chat] else {
            return nil
        }
        
        return chats
    }
    
    static func updateChat(chatObjectID: NSManagedObjectID, withChatID chatID: Int64) async throws {
        // Update using CDClient
        try await CDClient.update(
            managedObjectID: chatObjectID,
            updater: {mo in
                guard let chat = mo as? Chat else {
                    return
                }
                
                chat.chatID = chatID
            })
    }
    
    static func updateChat(chatObjectID: NSManagedObjectID, withText text: String) async throws {
        // Update using CDClient
        guard let chatNewContext = try await CDClient.update(
            managedObjectID: chatObjectID,
            updater: {mo in
                guard let chat = mo as? Chat else {
                    return
                }
                
                chat.text = text
            }) as? Chat else {
            return
        }
    }
    
}
