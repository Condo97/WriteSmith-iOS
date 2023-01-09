//
//  UIConstants.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import UIKit
import Foundation

struct Constants {
    static let bottomButtonGradient = UIColor(named: "BottomButtonGradient")!
    static let chatStorageUserDefaultKey = "chatStorageUserDefaultKey"
    static let pastChatStorageUserDefaultKey = "pastChatStorageUserDefaultKey"
}

struct HTTPSConstants {
    static let chatSonicURL = URL(string: "https://api.writesonic.com/v2/business/content/chatsonic?engine=premium")
}

enum ChatSender: Codable {
    case user
    case ai
}


