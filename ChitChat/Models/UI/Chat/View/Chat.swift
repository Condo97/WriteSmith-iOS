//
//  Chat.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/22/23.
//

import Foundation

protocol Chat: Codable {
    var text: String { get set }
    var sender: ChatSender { get set }
}
