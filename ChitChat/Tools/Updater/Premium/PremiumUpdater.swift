//
//  MainNavigationController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/2/23.
//

import Foundation

class PremiumUpdater: Updater {
    
    var updaterDelegate: Any?
    
    required init() {
        
    }
    
    func fullUpdate(completion: (()->Void)?) {
        // Do an full update from the WriteSmith server, should only be called once per load
        ensure(completion: {isPremium in
            // Call updateDelegate
//            self.updaterDelegate?.updatePremium(isPremium: isPremium)
            if let premiumUpdaterDelegate = self.updaterDelegate as? PremiumUpdaterDelegate {
                premiumUpdaterDelegate.updatePremium(isPremium: isPremium)
            }
            
            completion?()
        })
    }
    
    func validateAndUpdateReceiptWithFullUpdate(receiptString: String, completion:(()->Void)?) {
        // Create validate and update receipt request
        let validateAndUpdateReceiptRequest = ValidateAndUpdateReceiptRequest(authToken: AuthHelper.get()!, receiptString: receiptString)
        
        // Validate and update receipt
        HTTPSConnector.validateAndUpdateReceipt(request: validateAndUpdateReceiptRequest, completion: { validateAndUpdateReceiptResponse in
            
            // Update is premium in user defaults with the value in the response
            self.updateIsPremiumInUserDefaults(validateAndUpdateReceiptResponse.body.isPremium)
            
            // Call full update with completion block
            self.fullUpdate(completion: {
                completion?()
            })
        })
    }
    
    //MARK: Private methods
    
    /***
     Ensures the user is premium by checking with WriteSmith server and updating UserDefaults values if necessary
     */
    private func ensure(completion: @escaping (Bool)->Void) {
        ensure(forceCheck: false, completion: completion)
    }

    /***
     Ensures the user is premium by checking with WriteSmith server and updating UserDefaults when either the cooldown finishes or if forceCheck is true
     */
    private func ensure(forceCheck: Bool, completion: @escaping (Bool)->Void) {
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

    private func doServerPremiumCheck(completion: @escaping (Bool)->Void) {
        if let receiptString = IAPHelper.getLocalReceiptString() {
            // Get the authToken
            AuthHelper.ensure(completion: {authToken in
                // Create request and send to server
                let validateAndUpdateReceiptRequest = ValidateAndUpdateReceiptRequest(authToken: authToken, receiptString: receiptString)
                HTTPSConnector.validateAndUpdateReceipt(request: validateAndUpdateReceiptRequest, completion: {validateAndUpdateReceiptResponse in
                    // Phew! Set and return if the user is Premium
                    let isPremium = validateAndUpdateReceiptResponse.body.isPremium

                    completion(self.updateIsPremiumInUserDefaults(isPremium))
                })
            })
        } else {
            // Since receiptString doesn't exist, user is not premium
            completion(updateIsPremiumInUserDefaults(false))
        }
    }

    private func getIsPremiumFromUserDefaults() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.userDefaultStoredIsPremium)
    }
    
    @discardableResult
    private func updateIsPremiumInUserDefaults(_ isPremium: Bool) -> Bool {
        // Update userDefaultStoredIsPremium
        UserDefaults.standard.set(isPremium, forKey: Constants.userDefaultStoredIsPremium)

        // Update last premium check date
        UserDefaults.standard.set(Date(), forKey: Constants.userDefaultStoredPremiumLastCheckDate)

        return isPremium
    }
    
}
