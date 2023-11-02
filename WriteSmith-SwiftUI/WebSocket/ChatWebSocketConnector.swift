//
//  ChatWebSocketConnector.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/17/23.
//

import Foundation

class ChatWebSocketConnector: WebSocketClient {
    
    static func getChatStream(request: GetChatRequest) -> SocketStream {
        // Set url
        let url = URL(string: "\(WebSocketConstants.chitChatWebSocketServer)\(WebSocketConstants.getChatStream)")!
        
        // Setup headers from GetChatRequest TODO: Make this better lol
        var headers: [String: String] = [
            "authToken": request.authToken,
            "inputText": request.inputText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        ]
        
        if let conversationID = request.conversationID {
            headers["conversationID"] = "\(conversationID)"
        }
        
        if let usePaidModel = request.usePaidModel {
            headers["usePaidModel"] = "\(usePaidModel)"
        }
        
        return connect(url: url, headers: headers)
    }
    
}
