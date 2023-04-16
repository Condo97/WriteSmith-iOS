//
//  ChatStorageHandler.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import Foundation

class ChatStorageHelper {
    // TODO: - Make this CoreData for a few reasons including the use of the Chat protocol!
    static func appendChat(chatObject: ChatObject) {
        var chatStorage = getAllChats()
        chatStorage.append(chatObject)
        
        if let data = try? JSONEncoder().encode(chatStorage) {
            UserDefaults.standard.set(data, forKey: Constants.chatStorageUserDefaultKey)
        }
    }

    static func getAllChats() -> [ChatObject] {
        guard let chatStorageData = UserDefaults.standard.data(forKey: Constants.chatStorageUserDefaultKey) else {
            return []
        }
        
        guard let chatStorage = try? JSONDecoder().decode([ChatObject].self, from: chatStorageData) else {
            return []
        }
        
        return chatStorage
    }
    
    static func clearChat() {
        let chatStorage = getAllChats()
        var chatHistory = getAllHistory()
        
        chatHistory.append(chatStorage)
        
        if let data = try? JSONEncoder().encode(chatHistory) {
            UserDefaults.standard.set(data, forKey: Constants.pastChatStorageUserDefaultKey)
        }
    }
    
    static func getAllHistory() -> [[ChatObject]] {
        guard let chatHistoryData = UserDefaults.standard.data(forKey: Constants.pastChatStorageUserDefaultKey) else {
            return [[]]
        }
        
        guard let chatHistory = try? JSONDecoder().decode([[ChatObject]].self, from: chatHistoryData) else {
            return [[]]
        }
        
        return chatHistory
    }
}
