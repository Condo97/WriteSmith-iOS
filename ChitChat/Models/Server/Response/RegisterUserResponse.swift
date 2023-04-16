//
//  RegisterUserResponse.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/29/23.
//

import Foundation

struct RegisterUserResponse: Codable {
    
    struct Body: Codable {
        
        var authToken: String
        
        enum CodingKeys: String, CodingKey {
            case authToken
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
