//
//  GetChatResponse.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

struct GetChatResponse: Codable {
    
    struct Body: Codable {
        
        var outputText: String
        var finishReason: String
        var remaining: Int
        
        enum CodingKeys: String, CodingKey {
            case outputText = "output"
            case finishReason
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
