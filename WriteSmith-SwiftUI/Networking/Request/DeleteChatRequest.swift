//
//  DeleteChatRequest.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 8/9/23.
//

import Foundation

struct DeleteChatRequest: Codable {
    
    var authToken: String
    var chatID: Int
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case chatID
    }
    
}
