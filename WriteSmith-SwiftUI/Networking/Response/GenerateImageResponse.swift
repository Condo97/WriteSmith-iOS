//
//  GenerateImageResponse.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/13/24.
//

import Foundation

struct GenerateImageResponse: Codable {
    
    struct Body: Codable {
        
        var imageData: String?
        var imageURL: String?
        var revisedPrompt: String?
        var remaining: Int?
        
        enum CodingKeys: String, CodingKey {
            case imageData
            case imageURL
            case revisedPrompt
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
