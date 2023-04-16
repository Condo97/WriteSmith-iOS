//
//  AuthHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

class AuthHelper {
    
    static func get() -> String? {
        return UserDefaults.standard.string(forKey: Constants.userDefaultStoredAuthTokenKey)
    }
    
    static func ensure(completion: ((String)->Void)?) {
        // If no authToken, register the user and update the authToken in UserDefaults
        if UserDefaults.standard.string(forKey: Constants.userDefaultStoredAuthTokenKey) == nil {
            HTTPSConnector.registerUser(completion: {response in
                // Set the authToken
                UserDefaults.standard.set(response.body.authToken, forKey: Constants.userDefaultStoredAuthTokenKey)
                
                // Call completion block
                completion?(UserDefaults.standard.string(forKey: Constants.userDefaultStoredAuthTokenKey)!)
            })
        } else {
            // Call completion block
            completion?(UserDefaults.standard.string(forKey: Constants.userDefaultStoredAuthTokenKey)!)
        }
    }
    
}
