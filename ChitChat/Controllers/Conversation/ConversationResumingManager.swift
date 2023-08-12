//
//  ConversationResumingManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/19/23.
//

import Foundation

class ConversationResumingManager: Any {
    
    static var cachedConversation: Conversation?
    
    static func getConversation() async -> Conversation? {
        guard let idURL = UserDefaults.standard.url(forKey: Constants.userDefaultStoredConversationToResume) else {
            return nil
        }
        
        return await ConversationCDHelper.getConversationBy(idURL: idURL)
    }
    
    static func setConversation(_ conversation: Conversation) {
        Task {
            try? await ConversationCDHelper.convertToPermanentID(conversation)
            UserDefaults.standard.set(conversation.objectID.uriRepresentation(), forKey: Constants.userDefaultStoredConversationToResume)
        }
    }
    
}
