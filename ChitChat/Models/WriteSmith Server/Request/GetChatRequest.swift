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
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case inputText
    }
    
}
