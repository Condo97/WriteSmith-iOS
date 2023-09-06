//
//  ConversationResumingManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/19/23.
//

import CoreData
import Foundation

class ConversationResumingManager: Any {
    
    static var cachedConversation: Conversation?
    
    static func getConversationObjectID() async -> NSManagedObjectID? {
        guard let idURL = UserDefaults.standard.url(forKey: Constants.userDefaultStoredConversationToResume) else {
            return nil
        }
        
        return await ConversationCDHelper.getConversationObjectIDBy(idURL: idURL)
    }
    
    static func setConversation(conversationObjectID: NSManagedObjectID) {
//            try? await ConversationCDHelper.convertToPermanentID(conversation)
        UserDefaults.standard.set(conversationObjectID.uriRepresentation(), forKey: Constants.userDefaultStoredConversationToResume)
    }
    
    static func setNil() {
        UserDefaults.standard.set(nil, forKey: Constants.userDefaultStoredConversationToResume)
    }
    
}
