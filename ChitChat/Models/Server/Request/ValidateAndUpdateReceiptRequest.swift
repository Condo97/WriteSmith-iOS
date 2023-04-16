//
//  ValidateAndUpdateReceiptRequest.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

struct ValidateAndUpdateReceiptRequest: Codable {
    
    var authToken: String
    var receiptString: String
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case receiptString
    }
    
}
