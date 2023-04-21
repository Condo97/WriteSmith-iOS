//
//  V4MigrationHandler.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/21/23.
//

import Foundation

class V3_5MigrationHandler {
    
    static func migrate() -> Bool {
        // Get all chats from ChatStorageHelperLegacy
        let chats = ChatStorageHelperLegacy.getAllChats()
        
        // Ensure there are chats in ChatStorageHelperLegacy
        guard chats.count > 0 else {
            return true
        }
        
        // Take chats from ChatStorageHelperLegacy and put them in one conversation
        let conversation = ConversationCDHelper.appendConversation()!
        chats.forEach({ chatObjectLegacy in
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
            ChatCDHelper.appendChat(sender: getSenderString(sender: chatObjectLegacy.sender), text: chatObjectLegacy.text, to: conversation)
        })
        
        // Set conversation as conversation in conversation resuming manager so that it will be loaded on first migration load
        ConversationResumingManager.conversation = conversation
        
        return true
    }
    
}
