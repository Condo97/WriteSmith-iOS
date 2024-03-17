//
//  ClassifyChatRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/12/24.
//

import Foundation

struct ClassifyChatRequest: Codable {
    
    var authToken: String
    var chat: String
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case chat
    }
    
}
