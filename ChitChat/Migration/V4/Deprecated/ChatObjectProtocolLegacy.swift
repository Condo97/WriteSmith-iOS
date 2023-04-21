//
//  ChatObjectProtocolLegacy.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/21/23.
//

import Foundation

protocol ChatObjectProtocolLegacy: Codable {
    
    var text: String { get set }
    var sender: ChatSenderLegacy { get set }
    
}
