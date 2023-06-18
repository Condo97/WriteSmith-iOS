//
//  IsPremiumResponse.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/16/23.
//

import Foundation

struct IsPremiumResponse: Codable {
    
    struct Body: Codable {
        
        var isPremium: Bool
        
        enum CodingKeys: String, CodingKey {
            case isPremium
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
