//
//  PremiumHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/2/23.
//

import Foundation

class PremiumHelper: Any {
    
    /***
     Gets the current premium status of the user
     */
    static func get() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium)
    }
    
    /***
     Ensures the user is premium by checking with WriteSmith server and updating UserDefaults values if necessary
     */
    static func ensure(completion: @escaping (Bool)->Void) {
        ensure(forceCheck: false, completion: completion)
    }
    
    /***
     Ensures the user is premium by checking with WriteSmith server and updating UserDefaults when either the cooldown finishes or if forceCheck is true
     */
    static func ensure(forceCheck: Bool, completion: @escaping (Bool)->Void) {
        // Get last time premium was checked
        if !forceCheck, let lastCheckDate = UserDefaults.standard.object(forKey: Constants.userDefaultStoredPremiumLastCheckDate) as? Date {
            // If it has been longer than the premiumCheckCooldownSeconds, check with the server again, otherwise just return the storedIsPremium value
            if -lastCheckDate.timeIntervalSinceNow > Constants.premiumCheckCooldownSeconds {
                // If receiptString is valid, do the server check, otherwise user is not premium
                
                doServerPremiumCheck(completion: completion)
            } else {
                // Not time to do server check, so just return the current receipt
                completion(getIsPremiumFromUserDefaults())
            }
        } else {
            // If forceCheck is false and there is no check date, check the server
            doServerPremiumCheck(completion: completion)
        }
    }
    
    private static func doServerPremiumCheck(completion: @escaping (Bool)->Void) {
        if let receiptString = IAPHelper.getLocalReceiptString() {
            // Get the authToken
            AuthHelper.ensure(completion: {authToken in
                // Create request and send to server
                let validateAndUpdateReceiptRequest = ValidateAndUpdateReceiptRequest(authToken: authToken, receiptID: receiptString)
                HTTPSConnector.validateAndUpdateReceipt(request: validateAndUpdateReceiptRequest, completion: {validateAndUpdateReceiptResponse in
                    // Phew! Set and return if the user is Premium
                    let isPremium = validateAndUpdateReceiptResponse.body.isPremium
                    
                    completion(updateIsPremiumInUserDefaults(isPremium))
                })
            })
        } else {
            // Since receiptString doesn't exist, user is not premium
            completion(updateIsPremiumInUserDefaults(false))
        }
    }
    
    private static func getIsPremiumFromUserDefaults() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium)
    }
    
    private static func updateIsPremiumInUserDefaults(_ isPremium: Bool) -> Bool {
        // Update userDefaultStoredIsPremium
        UserDefaults.standard.set(isPremium, forKey: Constants.userDefaultStoredIsPremium)
        
        // Update last premium check date
        UserDefaults.standard.set(Date(), forKey: Constants.userDefaultStoredPremiumLastCheckDate)
        
        return isPremium
    }
    
}
