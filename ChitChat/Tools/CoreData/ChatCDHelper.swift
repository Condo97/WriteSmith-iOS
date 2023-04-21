//
//  ChatCDHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/18/23.
//

import Foundation

class ChatCDHelper: Any {
    
    static let chatEntityName = Chat.entity().name!
    
    @discardableResult
    static func appendChat(sender: String, text: String, to conversation: Conversation) -> Chat? {
        do {
            let chat = try CDClient.insert(named: chatEntityName) as! Chat
            
            chat.sender = sender
            chat.text = text
            chat.date = Date()
            
            conversation.addToChats(chat)
            
            do {
                try CDClient.saveContext()
                
                return chat
            } catch {
                print("Error saving context when appending Chat... \(error)")
                
                return nil
            }
        } catch {
            print("Error inserting Chat... \(error)")
            
            return nil
        }
    }
    
    static func getOrderedChatArray(from conversation: Conversation) -> [Chat] {
        let chats = conversation.chats!.sortedArray(using: [NSSortDescriptor(key: #keyPath(Chat.date), ascending: true)])
        
        return chats as! [Chat]
    }
    
//    static func getMostRecentChat(from conversation: Conversation) -> Chat? {
//        //Does this in O(n)
//        guard conversation.chats!.count > 0 else {
//            return nil
//        }
//
//        var mostRecentChat: Chat?
//
//        for chatAny in conversation.chats! {
//            if let chat = chatAny as? Chat {
//                if let date = chat.date {
//                    if mostRecentChat == nil {
//                        mostRecentChat = chat
//                    } else {
//                        if date > mostRecentChat!.date! {
//                            mostRecentChat = chat
//                        }
//                    }
//                }
//            }
//        }
//
//        return mostRecentChat
//    }
    
}
