//
//  GetChatRequest.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

struct GetChatRequest: Codable {
    
    var authToken: String
    var inputText: String
    var conversationID: Int64?
    var usePaidModel: Bool?
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case inputText
        case conversationID
        case usePaidModel
    }
    
}
