//
//  RemainingStructureUpdater.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/15/23.
//

import Foundation

class GeneratedChatsRemainingUpdater: Updater {
    
    var updaterDelegate: Any?
    
    required init() {
        
    }
    
    func fullUpdate(completion: (()->Void)?) {
        // Get authToken and get remaining
        AuthHelper.ensure(completion: {authToken in
            let authRequest = AuthRequest(authToken: authToken)
            HTTPSConnector.getRemaining(request: authRequest, completion: {getRemainingResponse in
                // Call updateDelegate
//                self.updateDelegate?.updateRemaining(remaining: getRemainingResponse.body.remaining)
                if let remainingUpdaterDelegate = self.updaterDelegate as? GeneratedChatsRemainingUpdaterDelegate {
                    remainingUpdaterDelegate.updateGeneratedChatsRemaining(remaining: self.updateGeneratedChatsRemainingInUserDefaults(getRemainingResponse.body.remaining))
                }
                
                completion?()
            })
        })
    }
    
    //MARK: Private methods
    
    /***
     Update premium in user defaults, and return the value for use in the delegate of getRemaining block
     */
    private func updateGeneratedChatsRemainingInUserDefaults(_ remaining: Int) -> Int {
        // Update userDefaultStoredRemainingChats
        UserDefaults.standard.set(remaining, forKey: Constants.userDefaultStoredGeneratedChatsRemaining)
        
        return remaining
    }
    
}
