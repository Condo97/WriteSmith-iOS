//
//  PreloadedResponseChatObject.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation

struct PreloadedResponseChatObject: Chat {
    var text: String
    var responseText: String
    
    var sender: ChatSender
    var responseSender: ChatSender
}
