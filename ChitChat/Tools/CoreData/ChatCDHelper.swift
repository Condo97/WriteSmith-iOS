//
//  ChatCDHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/18/23.
//

import Foundation

class ChatCDHelper {
    
    static let chatEntityName = String(describing: Chat.self)
    
    @discardableResult
    static func appendChat(sender: String, text: String, to conversation: inout Conversation) async throws -> Chat? {
        // Build and save new chat to parent conversation
        let (childManagedObject, parentManagedObject) = try await CDClient.buildAndSaveToParent(
            named: chatEntityName,
            to: conversation.objectID,
            builder: {cmo, pmo in
                guard let chat = cmo as? Chat, let conversation = pmo as? Conversation else {
                    return
                }
                
                chat.sender = sender
                chat.text = text
                chat.date = Date()
                chat.conversation = conversation
            })
        
        // Unwrap chat and conversationNewContext
        guard let chat = childManagedObject as? Chat, let conversationNewContext = parentManagedObject as? Conversation else {
            return nil
        }
        
        // Set conversation to conversationNewContext after chat has been added
        conversation = conversationNewContext
        
        return chat
    }
    
    static func deleteChat(chat: inout Chat) async throws {
        guard let chatNewContext = try await CDClient.delete(managedObjectID: chat.objectID) as? Chat else {
            // TODO: Handle error
            print("Could not unwrap chatNewContext in deleteChat in ChatCDHelper!")
            return
        }
        
        chat = chatNewContext
    }
    
    static func getOrderedChatArray(from conversation: inout Conversation) async throws -> [Chat]? {
        // Sync conversation
        try await ConversationCDHelper.sync(&conversation)
        
        // Create date sorted array from conversation chats
        guard let chats = conversation.chats?.sortedArray(using: [NSSortDescriptor(key: #keyPath(Chat.date), ascending: true)]) as? [Chat] else {
            return nil
        }
        
        return chats
    }
    
    static func updateChat(_ chat: inout Chat, withChatID chatID: Int64) async throws {
        // Update using CDClient
        guard let chatNewContext = try await CDClient.update(
            managedObjectID: chat.objectID,
            updater: {mo in
                guard let chat = mo as? Chat else {
                    return
                }
                
                chat.chatID = chatID
            }) as? Chat else {
                return
            }
        
        chat = chatNewContext
    }
    
    static func updateChat(_ chat: inout Chat, withText text: String) async throws {
        // Update using CDClient
        guard let chatNewContext = try await CDClient.update(
            managedObjectID: chat.objectID,
            updater: {mo in
                guard let chat = mo as? Chat else {
                    return
                }
                
                chat.text = text
            }) as? Chat else {
            return
        }
        
        // Set chat to chatNewContext after it's been updated
        chat = chatNewContext
    }
    
}
