//
//  MainNavigationController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/2/23.
//

import Foundation

class PremiumUpdater: Updater {
    
    // TODO: This probably should be somewhere else I think
    let activeSubscriptionState: Int = 1;
    
    var updaterDelegate: Any?
    
    required init() {
        
    }
    
    func forceUpdate() async throws {
        // TODO: Is there a way to decouple this from AuthHelper, or is it just fine?
        try await forceUpdate(authToken: try await AuthHelper.ensure())
    }
    
    func forceUpdate(authToken: String) async throws {
        let isPremium = try await ensure(authToken: authToken)
        
        notifyDelegate(isPremium: isPremium)
    }
    
    func registerTransaction(authToken: String, transactionID: UInt64) async throws -> Bool {
        // Register transaction and get isPremium
        let isPremium = try await TransactionHTTPSConnector.registerTransaction(authToken: authToken, transactionID: transactionID).body.isPremium
        
        return updateIsPremiumInUserDefaults(isPremium)
    }
    
    //MARK: Private methods
    
    /***
     Ensures the user is premium by checking with WriteSmith server and updating UserDefaults values if necessary
     */
    private func ensure(authToken: String) async throws -> Bool {
        return try await ensure(authToken: authToken, forceCheck: false)
    }

    /***
     Ensures the user is premium by checking with WriteSmith server and updating UserDefaults when either the cooldown finishes or if forceCheck is true
     */
    private func ensure(authToken: String, forceCheck: Bool) async throws -> Bool {
        // Get last time premium was checked
        if !forceCheck, let lastCheckDate = UserDefaults.standard.object(forKey: Constants.userDefaultStoredPremiumLastCheckDate) as? Date {
            // If it has been longer than the premiumCheckCooldownSeconds, check with the server again, otherwise just return the storedIsPremium value
            if -lastCheckDate.timeIntervalSinceNow > Constants.premiumCheckCooldownSeconds {
                // If receiptString is valid, do the server check, otherwise user is not premium

                return try await doServerPremiumCheck(authToken: authToken)
            } else {
                // Not time to do server check, so just return the current receipt
                return getIsPremiumFromUserDefaults()
            }
        } else {
            // If forceCheck is false and there is no check date, check the server
            return try await doServerPremiumCheck(authToken: authToken)
        }
    }

    private func doServerPremiumCheck(authToken: String) async throws -> Bool {
        // Build authRequest
        let authRequest = AuthRequest(authToken: authToken)
        
        // Get isPremium in response from server
        let isPremiumResponse = try await HTTPSConnector.getIsPremium(request: authRequest)
        
        // Update isPremium in user defaults
        return updateIsPremiumInUserDefaults(isPremiumResponse.body.isPremium)
    }

    private func getIsPremiumFromUserDefaults() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium)
    }
    
    private func notifyDelegate(isPremium: Bool) {
        if let premiumUpdaterDelegate = self.updaterDelegate as? PremiumUpdaterDelegate {
            premiumUpdaterDelegate.updatePremium(isPremium: isPremium)
        }
    }
    
    @discardableResult
    private func updateIsPremiumInUserDefaults(_ isPremium: Bool) -> Bool {
        // If isPremium was changed, set willNotifyDelegate to true to call delegate after setting isPremium and check date in user defaults
        var willNotifyDelegate = false
        if UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium) != isPremium {
            willNotifyDelegate = true
        }
        
        // Update userDefaultStoredIsPremium
        UserDefaults.standard.set(isPremium, forKey: Constants.userDefaultStoredIsPremium)

        // Update last premium check date
        UserDefaults.standard.set(Date(), forKey: Constants.userDefaultStoredPremiumLastCheckDate)
        
        if willNotifyDelegate {
            notifyDelegate(isPremium: isPremium)
        }

        return isPremium
    }
    
}
