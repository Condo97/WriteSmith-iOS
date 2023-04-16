//
//  ValidateAndUpdateReceiptResponse.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

struct ValidateAndUpdateReceiptResponse: Codable {
    
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
