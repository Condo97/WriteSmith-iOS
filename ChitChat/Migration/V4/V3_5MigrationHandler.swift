//
//  V4MigrationHandler.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/21/23.
//

import Foundation

class V3_5MigrationHandler {
    
    static func migrate() async {
        // Get all chats from ChatStorageHelperLegacy
        let chats = ChatStorageHelperLegacy.getAllChats()
        
        // Ensure there are chats in ChatStorageHelperLegacy
        guard chats.count > 0 else {
            return
        }
        
        // Take chats from ChatStorageHelperLegacy and put them in one conversation
        guard var conversationObjectID = try? await ConversationCDHelper.appendConversation() else {
            return
        }
        for chatObjectLegacy in chats {
            // Get sender string for chatObjectLegacy sender
            func getSenderString(sender: ChatSenderLegacy) -> String {
                switch sender {
                case .user:
                    return Constants.Chat.Sender.user
                case .ai:
                    return Constants.Chat.Sender.ai
                }
            }
            
            // Append Chat from chatObjectLegacy to conversation
            do {
                try await ChatCDHelper.appendChat(sender: getSenderString(sender: chatObjectLegacy.sender), text: chatObjectLegacy.text, to: conversationObjectID)
            } catch {
                // TODO: Handle errors
                print("Could not append chat from chatObjectLegacy to conversation!")
            }
        }
        
        // Set conversation as conversation in conversation resuming manager so that it will be loaded on first migration load
        ConversationResumingManager.setConversation(conversationObjectID: conversationObjectID)
    }
    
}
