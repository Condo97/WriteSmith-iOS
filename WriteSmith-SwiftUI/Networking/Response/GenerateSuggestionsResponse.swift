//
//  GenerateSuggestionsResponse.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/3/24.
//

import Foundation

struct GenerateSuggestionsResponse: Codable {
    
    struct Body: Codable {
        var suggestions: [String]
        
        enum CodingKeys: String, CodingKey {
            case suggestions
        }
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
