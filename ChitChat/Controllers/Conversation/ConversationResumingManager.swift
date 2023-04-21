//
//  ConversationResumingManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/19/23.
//

import Foundation

class ConversationResumingManager: Any {
    
    static var conversation: Conversation? {
        get {
            guard let idURL = UserDefaults.standard.url(forKey: Constants.userDefaultStoredConversationToResume) else {
                return nil
            }
            
            return ConversationCDHelper.getConversationBy(idURL: idURL)
        }
        set {
            UserDefaults.standard.set(newValue?.objectID.uriRepresentation(), forKey: Constants.userDefaultStoredConversationToResume)
        }
    }
    
}
