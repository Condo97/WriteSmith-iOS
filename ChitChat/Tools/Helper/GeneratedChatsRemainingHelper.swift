//
//  RemainingHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/15/23.
//

import Foundation

class GeneratedChatsRemainingHelper: Any {
    
    /***
     Gets the current chats remaining for the user
     */
    static func get() -> Int {
        return UserDefaults.standard.integer(forKey: Constants.userDefaultStoredGeneratedChatsRemaining)
    }
    
    /***
     Ensures the 
     */
    
    
}
