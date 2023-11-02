//
//  ConversationResumingManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/19/23.
//

import CoreData
import Foundation

class ConversationResumingManager: Any {
    
    static func getConversation(in managedContext: NSManagedObjectContext) throws -> Conversation? {
        // If everything can be unwrapped and everything is successful return conversation, otherwise return nil
        if let conversationObjectIDURIRepresentation = getConversationObjectIDURLRepresentation(),
           let conversationObjectID = managedContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: conversationObjectIDURIRepresentation),
           let conversation = try managedContext.existingObject(with: conversationObjectID) as? Conversation {
           return conversation
        }
        
        return nil
    }
    
    private static func getConversationObjectIDURLRepresentation() -> URL? {
        UserDefaults.standard.url(forKey: Constants.UserDefaults.userDefaultStoredConversationToResume)
    }
    
    static func setConversation(_ conversation: Conversation, in managedContext: NSManagedObjectContext) throws {
        // Obtain permanent ID and set conversation to its URI representation
        try managedContext.obtainPermanentIDs(for: [conversation])
        setConversationObjectIDURLRepresentation(conversation.objectID.uriRepresentation())
    }
    
    private static func setConversationObjectIDURLRepresentation(_ conversationObjectIDURLRepresentationToResume: URL) {
//            try? await ConversationCDHelper.convertToPermanentID(conversation)
        UserDefaults.standard.set(conversationObjectIDURLRepresentationToResume, forKey: Constants.UserDefaults.userDefaultStoredConversationToResume)
    }
    
    static func setNil() {
        UserDefaults.standard.set(nil, forKey: Constants.UserDefaults.userDefaultStoredConversationToResume)
    }
    
}
