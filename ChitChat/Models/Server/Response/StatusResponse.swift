//
//  StatusREsponse.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 8/9/23.
//

import Foundation

struct StatusResponse: Codable {
    
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case success = "Success"
    }
    
}
