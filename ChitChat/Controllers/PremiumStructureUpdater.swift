//
//  MainNavigationController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/2/23.
//

import Foundation

protocol PremiumStructureUpdaterDelegate {
    func updatePremium(isPremium: Bool)
    func updateRemaining(remaining: Int)
}

class PremiumStructureUpdater: Any {
    
    var updateDelegate: PremiumStructureUpdaterDelegate?
    
    func fullUpdate() {
        // Do an full update from the WriteSmith server, should only be called once per load
        PremiumHelper.ensure(completion: {isPremium in
            // Call updateDelegate
            self.updateDelegate?.updatePremium(isPremium: isPremium)
            
            // If not premium, get amount remaining and update
            if !isPremium {
                // Get authToken and get remaining
                AuthHelper.ensure(completion: {authToken in
                    let authRequest = AuthRequest(authToken: authToken)
                    HTTPSConnector.getRemaining(request: authRequest, completion: {getRemainingResponse in
                        // Call updateDelegate
                        self.updateDelegate?.updateRemaining(remaining: getRemainingResponse.body.remaining)
                    })
                })
            }
        })
    }
    
}
