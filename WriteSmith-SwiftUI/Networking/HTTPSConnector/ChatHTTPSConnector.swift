//
//  ChatHTTPSConnector.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/3/23.
//

import Foundation

class ChatHTTPSConnector {
    
    static func deleteChat(authToken: String, chatID: Int) async throws {
        // Create deleteChatRequest
        let deleteChatRequest = DeleteChatRequest(authToken: authToken, chatID: chatID)
        
        // Delete chat from HTTPSConnector TODO: Handle errors and statusResponse
        try await HTTPSConnector.deleteChat(request: deleteChatRequest)
    }
    
}
