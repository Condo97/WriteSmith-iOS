//
//  CheckIfChatRequestsImageRevisionResponse.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/12/24.
//

import Foundation

struct CheckIfChatRequestsImageRevisionResponse: Codable {
    
    struct Body: Codable {
        
        var requestsImageRevision: Bool
        
        enum CodingKeys: String, CodingKey {
            case requestsImageRevision
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
