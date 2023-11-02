//
//  PremiumUpdater.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/7/23.
//

import Foundation
import SwiftUI

class PremiumUpdater: ObservableObject {
    
    @Published var isPremium: Bool = persistentIsPremium
    
    
    private static var persistentIsPremium: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.UserDefaults.userDefaultStoredIsPremium)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.userDefaultStoredIsPremium)
        }
    }
    
    static func get() -> Bool {
        UserDefaults.standard.bool(forKey: Constants.UserDefaults.userDefaultStoredIsPremium)
    }
    
    func registerTransaction(authToken: String, transactionID: UInt64) async throws {
        // Get isPremiumResponse from server with authToken and transactionID
        let isPremiumResponse = try await TransactionHTTPSConnector.registerTransaction(
            authToken: authToken,
            transactionID: transactionID)
        
        // Update with isPremium value
        update(isPremium: isPremiumResponse.body.isPremium)
    }
    
    func update(authToken: String) async throws {
        // Create authRequest
        let authRequest = AuthRequest(authToken: authToken)
        
        // Get isPremiumResponse from server
        let isPremiumResponse = try await HTTPSConnector.getIsPremium(request: authRequest)
        
        // Update with isPremium value
        update(isPremium: isPremiumResponse.body.isPremium)
    }
    
    private func update(isPremium: Bool) {
        // Set persistentIsPremium to isPremium and self.isPremium to persistentIsPremium
        PremiumUpdater.persistentIsPremium = isPremium
        
        DispatchQueue.main.async {
            self.isPremium = PremiumUpdater.persistentIsPremium
        }
    }
    
}
