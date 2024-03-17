//
//  ClassifyChatResponse.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/12/24.
//

import Foundation

struct ClassifyChatResponse: Codable {
    
    struct Body: Codable {
        
        var wantsImageGeneration: Bool
        
        enum CodingKeys: String, CodingKey {
            case wantsImageGeneration
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
