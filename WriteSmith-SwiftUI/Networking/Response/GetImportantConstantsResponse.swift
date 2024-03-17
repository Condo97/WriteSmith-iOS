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
        
        var priceVAR2DisplayChance: Double?
        
        var weeklyProductID_VAR1: String?
        var weeklyProductID_VAR2: String?
        var monthlyProductID_VAR1: String?
        var monthlyProductID_VAR2: String?
//        var annualProductID: String?
        
        var weeklyDisplayPrice_VAR1: String?
        var weeklyDisplayPrice_VAR2: String?
//        var weeklyIntroductoryOfferPrice: String?
        
        var monthlyDisplayPrice_VAR1: String?
        var monthlyDisplayPrice_VAR2: String?
//        var monthlyIntroductoryOfferPrice: String?
        
        var annualDisplayPrice: String?
//        var annualIntroductoryOfferPrice: String?
        
        var shareURL: String
        var freeEssayCap: Int
        var appLaunchAlert: String
        
        enum CodingKeys: String, CodingKey {
            case sharedSecret
            case priceVAR2DisplayChance
            case weeklyProductID_VAR1
            case weeklyProductID_VAR2
            case monthlyProductID_VAR1
            case monthlyProductID_VAR2
            case weeklyDisplayPrice_VAR1
            case weeklyDisplayPrice_VAR2
            case monthlyDisplayPrice_VAR1
            case monthlyDisplayPrice_VAR2
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
