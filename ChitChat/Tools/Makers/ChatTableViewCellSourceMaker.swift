//
//  ChatTableViewCellSourceBuilder.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/20/23.
//

import Foundation

class ChatTableViewCellSourceMaker: Any {
    
    static func makeChatTableViewCellSource(fromChatObject chatObject: Chat) -> ChatTableViewCellSource {
        return makeChatTableViewCellSourceArray(fromChatObjectArray: [chatObject])[0]
    }
    
    static func makeChatTableViewCellSourceArray(fromChatObjectArray chatObjectArray: [Chat]) -> [ChatTableViewCellSource] {
        var sourceArray: [ChatTableViewCellSource] = []
        
        for obj in chatObjectArray {
            sourceArray.append(ChatTableViewCellSource(chat: obj, typewriter: nil))
        }
        
        return sourceArray
    }
}
