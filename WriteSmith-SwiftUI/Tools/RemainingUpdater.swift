//
//  RemainingUpdater.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/31/23.
//

import Foundation

class RemainingUpdater: ObservableObject {
    
    @Published var remaining: Int? = persistentRemaining
    
    
    private static var persistentRemaining: Int {
        get {
            UserDefaults.standard.integer(forKey: Constants.UserDefaults.userDefaultStoredGeneratedChatsRemaining)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.userDefaultStoredGeneratedChatsRemaining)
        }
    }
    
    func set(drinksRemaining: Int) {
        RemainingUpdater.persistentRemaining = drinksRemaining
        
        DispatchQueue.main.async {
            self.remaining = drinksRemaining
        }
    }
    
    func update(authToken: String) async throws {
        // Build authRequest
        let authRequest = AuthRequest(authToken: authToken)
        
        // Do request
        let remainingResponse = try await HTTPSConnector.getRemaining(request: authRequest)//BarbackNetworkService.getRemainingDrinks(request: authRequest)
        
        // Set persistentRemaining to response remainingDrinks
        set(drinksRemaining: remainingResponse.body.remaining)
    }
    
}
