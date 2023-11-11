//
//  GetIAPStuffResponse.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

struct GetIAPStuffResponse: Codable {
    
    struct Body: Codable {
        
        var sharedSecret: String
        var productIDs: [String]
        
        enum CodingKeys: String, CodingKey {
            case sharedSecret
            case productIDs
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
