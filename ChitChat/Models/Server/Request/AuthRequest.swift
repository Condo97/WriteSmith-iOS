//
//  AuthRequest.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

struct AuthRequest: Codable {
    
    var authToken: String
    
    enum CodingKeys: String, CodingKey {
        case authToken
    }
    
}
