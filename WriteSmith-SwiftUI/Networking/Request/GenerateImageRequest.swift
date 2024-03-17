//
//  GenerateImageRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/13/24.
//

import Foundation

struct GenerateImageRequest: Codable {
    
    var authToken: String
    var prompt: String
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case prompt
    }
    
}
