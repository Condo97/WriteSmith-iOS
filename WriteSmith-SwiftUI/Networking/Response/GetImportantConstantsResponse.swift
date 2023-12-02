//
//  GetImportantConstantsResponse.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

struct GetImportantConstantsResponse: Codable {
    
    struct Body: Codable {
        
        var sharedSecret: String?
        
        var weeklyProductID: String?
        var monthlyProductID: String?
        var annualProductID: String?
        
        var weeklyDisplayPrice: String?
//        var weeklyIntroductoryOfferPrice: String?
        
        var monthlyDisplayPrice: String?
//        var monthlyIntroductoryOfferPrice: String?
        
        var annualDisplayPrice: String?
//        var annualIntroductoryOfferPrice: String?
        
        var shareURL: String
        var freeEssayCap: Int
        var appLaunchAlert: String
        
        enum CodingKeys: String, CodingKey {
            case sharedSecret
            case weeklyProductID
            case monthlyProductID
            case annualProductID
            case weeklyDisplayPrice
            case monthlyDisplayPrice
            case annualDisplayPrice
            case shareURL
            case freeEssayCap
            case appLaunchAlert
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
