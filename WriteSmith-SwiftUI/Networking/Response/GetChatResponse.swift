//
//  GetChatResponse.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

struct GetChatResponse: Codable {
    
    struct Body: Codable {
        
        struct Chat: Codable {
            
            var index: Int
            var chatID: Int
            
            enum CodingKeys: String, CodingKey {
                case index
                case chatID
            }
            
        }
        
        var outputText: String?
        var finishReason: String?
        var conversationID: Int?
        var inputChats: [GetChatResponse.Body.Chat]?
        var outputChatID: Int?
        var remaining: Int?
        
        enum CodingKeys: String, CodingKey {
            case outputText = "output"
            case finishReason
            case conversationID
            case inputChats
            case outputChatID
            case remaining
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
