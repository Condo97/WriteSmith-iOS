//
//  FeedbackRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/2/24.
//

import Foundation

struct SubmitFeedbackRequest: Codable {
    
    var authToken: String
    var feedback: String
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case feedback
    }
    
}
