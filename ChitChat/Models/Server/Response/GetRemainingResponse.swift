//
//  GetRemainingResponse.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

struct GetRemainingResponse: Codable {
    
    struct Body: Codable {
        
        var remaining: Int
        
        enum CodingKeys: String, CodingKey {
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
