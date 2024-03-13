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
    
    static func appendChat(sender: Sender, text: String, to conversation: Conversation, in managedContext: NSManagedObjectContext) throws {
        // Build and save new chat to parent conversation
        try managedContext.performAndWait {
            // Create Chat in managedContext
            let chat = Chat(context: managedContext)
            
            // Get current date for chat and conversation
            let date = Date()
            
            // Update chat values
            chat.sender = sender.rawValue
            chat.text = text
            chat.date = date
            chat.conversation = conversation
            
            // Update conversation latestChatDate and latestChatText TODO: Is this appropriate to do here? I guess this is the best place lol
            conversation.latestChatDate = date
            conversation.latestChatText = text
            
            try managedContext.save()
        }
    }
    
    static func deleteChat(chat: Chat, in managedContext: NSManagedObjectContext) throws {
        managedContext.delete(chat)
        
        try managedContext.performAndWait {
            try managedContext.save()
        }
    }
    
//    static func getOrderedChatArray(conversationObjectID: NSManagedObjectID) async throws -> [Chat]? {
////        // Sync conversation
////        try await ConversationCDHelper.sync(&conversation)
////        guard let chats = try await CDClient.getAll(in: chatEntityName, where: [#keyPath(Chat.conversation): conversation], sortDescriptors: [NSSortDescriptor(key: #keyPath(Chat.date), ascending: true)]) as? [Chat] else {
////            return nil
////        }
////
////        return chats;
//
//        // Create date sorted array from conversation chats
////        conversation.willAccessValue(forKey: chatEntityName)
////        print(conversation.isFault)
////        print(conversation.chats)
//        guard let chats = try await CDClient.getAll(
//            in: chatEntityName,
//            where: [#keyPath(Chat.conversation): conversationObjectID]
//        ) as? [Chat] else {
//            return nil
//        }
//
//        return chats
//    }
    
//    static func updateChat(chat: Chat, with in managedContext: NSManagedObjectContext) async throws {
//        // Update using CDClient
//        managedContext.performAndWait {
//            chat.
//
//            managedObjectID: chatObjectID,
//            updater: {mo in
//                guard let chat = mo as? Chat else {
//                    return
//                }
//
//                chat.chatID = chatID
//            })
//    }
//
//    static func updateChat(chatObjectID: NSManagedObjectID, withText text: String) async throws {
//        // Update using CDClient
//        guard let chatNewContext = try await CDClient.update(
//            managedObjectID: chatObjectID,
//            updater: {mo in
//                guard let chat = mo as? Chat else {
//                    return
//                }
//
//                chat.text = text
//            }) as? Chat else {
//            return
//        }
//    }
    
}
