//
//  GetImportantConstantsResponse.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

struct GetImportantConstantsResponse: Codable {
    
    struct Body: Codable {
        
        var weeklyDisplayPrice: String
        var monthlyDisplayPrice: String
        var annualDisplayPrice: String
        var shareURL: String
        var freeEssayCap: Int
        
        enum CodingKeys: String, CodingKey {
            case weeklyDisplayPrice
            case monthlyDisplayPrice
            case annualDisplayPrice
            case shareURL
            case freeEssayCap
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
