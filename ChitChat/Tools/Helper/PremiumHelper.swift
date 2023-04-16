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
    
}
