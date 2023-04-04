//
//  AuthHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

class AuthHelper {
    
    static func ensure(completion: ((String)->Void)?) {
        // If no authToken, register the user and update the authToken in UserDefaults
        if UserDefaults.standard.string(forKey: Constants.authTokenKey) == nil {
            HTTPSConnector.registerUser(completion: {response in
                // Set the authToken
                UserDefaults.standard.set(response.body.authToken, forKey: Constants.authTokenKey)
                
                // Call completion block
                completion?(UserDefaults.standard.string(forKey: Constants.authTokenKey)!)
            })
        } else {
            // Call completion block
            completion?(UserDefaults.standard.string(forKey: Constants.authTokenKey)!)
        }
    }
    
}
