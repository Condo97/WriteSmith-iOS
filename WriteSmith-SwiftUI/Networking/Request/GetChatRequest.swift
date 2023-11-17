//
//  GetChatRequest.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

struct GetChatRequest: Codable {
    
    struct Chat: Codable {
        
        var index: Int
        var input: String?
        var imageData: Data?
        var imageURL: String?
        var sender: Sender
        
        init(index: Int, input: String?, imageData: Data?, imageURL: String?, sender: Sender) {
            self.index = index
            self.input = input
            self.imageData = imageData
            self.imageURL = imageURL
            self.sender = sender
        }
        
        enum CodingKeys: String, CodingKey {
            case index
            case input
            case imageData
            case imageURL
            case sender
        }
        
    }
    
    var authToken: String
    var behavior: String?
    var chats: [GetChatRequest.Chat]
    var conversationID: Int64?
    var usePaidModel: Bool?
    
    
    init(authToken: String, behavior: String?, chats: [GetChatRequest.Chat], conversationID: Int64?, usePaidModel: Bool?) {
        self.authToken = authToken
        self.behavior = behavior
        self.chats = chats
        self.conversationID = conversationID
        self.usePaidModel = usePaidModel
    }
    
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case chats
        case conversationID
        case usePaidModel
    }
    
}

extension GetChatRequest {
    
    class Builder {
        
        var authToken: String
        var behavior: String?
        var chats: [GetChatRequest.Chat] = []
        var conversationID: Int64?
        var usePaidModel: Bool?
        
        init(authToken: String, behavior: String?, conversationID: Int64?, usePaidModel: Bool?) {
            self.authToken = authToken
            self.behavior = behavior
            self.conversationID = conversationID
            self.usePaidModel = usePaidModel
        }
        
        func addChat(index: Int, input: String?, imageData: Data?, imageURL: String?, sender: Sender) -> Self {
            chats.append(
                GetChatRequest.Chat(
                    index: index,
                    input: input,
                    imageData: imageData,
                    imageURL: imageURL,
                    sender: sender)
            )
            
            return self
        }
        
        func build() -> GetChatRequest {
            GetChatRequest(
                authToken: authToken,
                behavior: behavior,
                chats: chats,
                conversationID: conversationID,
                usePaidModel: usePaidModel)
        }
        
    }
    
}
