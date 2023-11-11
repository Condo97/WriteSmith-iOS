//
//  RegisterTransactionRequest.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/16/23.
//

import Foundation

struct RegisterTransactionRequest: Codable {
    
    var authToken: String
    var transactionId: UInt64

    enum CodingKeys: String, CodingKey {
        case authToken
        case transactionId
        
    }
    
}
