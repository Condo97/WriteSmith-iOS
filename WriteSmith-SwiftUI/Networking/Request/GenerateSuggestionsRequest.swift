//
//  GenerateSuggestionsRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/3/24.
//

import Foundation

struct GenerateSuggestionsRequest: Codable {
    
    var authToken: String
    var conversation: [String]
    var differentThan: [String]?
    var count: Int
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case conversation
        case differentThan
        case count
    }
    
}
