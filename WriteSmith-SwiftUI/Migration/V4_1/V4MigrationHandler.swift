//
//  V4MigrationHandler.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/1/23.
//

import CoreData
import Foundation

class V4MigrationHandler {
    
    static func migrate(in context: NSManagedObjectContext) async throws {
        // TODO: Migrate latestChatDate and latestChatText in Conversation from the latest Chat date
        
//        // Ensure migration has not been completed, otherwise return
//        guard !UserDefaults.standard.bool(forKey: Constants.Migration.userDefaultStoredV4MigrationComplete) else {
//            print("Migration has already been completed!")
//            return
//        }
        
        try context.performAndWait {
            // Get all Conversations
            let fetchRequest = Conversation.fetchRequest()
            let conversations = try context.fetch(fetchRequest)
            
            //        guard let conversations = await ConversationCDHelper.getAllConversations() else {
            //            print("Could not get all conversations in V4MigrationHandler migrate!")
            //            return
            //        }
            
            // For each conversation, get the latest chat date and text and update the conversation with them :)
            for conversation in conversations {
                // Get latestChatDate and latestChatText from conversationManagedObjectID
                let (latestChatDate, latestChatText) = try getLatestChatTextAndDateInConversation(conversationManagedObjectID: conversation.objectID)
                
                // Unwrap latestChatDate and update conversation latestChatDate if successfull
                if let latestChatDate = latestChatDate {
//                    try await ConversationCDHelper.updateConversation(conversationObjectID: conversation.objectID, withLatestChatDate: latestChatDate)
                    conversation.latestChatDate = latestChatDate
                }
                
                // Unwrap latestChatText and update conversation latestChatText if successful
                if let latestChatText = latestChatText {
//                    try await ConversationCDHelper.updateConversation(conversationObjectID: conversation.objectID, withLatestChatText: latestChatText)
                    conversation.latestChatText = latestChatText
                }
            }
            
            // Save context
            try context.save()
        }
    }
    
    private static func getLatestChatTextAndDateInConversation(conversationManagedObjectID: NSManagedObjectID) throws -> (Date?, String?) {
        // Create fetch request for latest Chat, and return its text and date
        let fetchRequest = Chat.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversationManagedObjectID)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Chat.date), ascending: false)]
        fetchRequest.fetchLimit = 1
        
        // Fetch on main context and return first chat text and date if there was at least one chat fetched, otherwise return both objects as nil
        let chats = try CDClient.mainManagedObjectContext.fetch(fetchRequest)
        guard chats.count > 0 else {
            // Is there a better way to handle errors here? What errors would there even be?
            return (nil, nil)
        }
        
        return (chats[0].date, chats[0].text)
    }
    
}
