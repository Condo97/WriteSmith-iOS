//
//  TransactionHTTPSConnector.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/16/23.
//

import Foundation

class TransactionHTTPSConnector {
    
    static func registerTransaction(authToken: String, transactionID: UInt64) async throws -> IsPremiumResponse {
        let request = RegisterTransactionRequest(authToken: authToken, transactionId: transactionID)
        
        return try await registerTransaction(request: request)
    }
    
    static func registerTransaction(request: RegisterTransactionRequest) async throws -> IsPremiumResponse {
        let (data, response) = try await HTTPSClient.post(
            url: URL(string: "\(HTTPSConstants.chitChatServer)\(HTTPSConstants.registerTransaction)")!,
            body: request,
            headers: nil)
        
        let isPremiumResponse = try JSONDecoder().decode(IsPremiumResponse.self, from: data)
        
        return isPremiumResponse
    }
    
}
