//
//  GPTModelViewComponents.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/9/23.
//

import Foundation

struct ChatGPTModelViewComponents {
    
    static let lightGifName = "GPTModelGifElementBackgroundColorLight"
    static let darkGifName = "GPTModelGifElementBackgroundColorDark"
    
    static var additionalText: String {
        get {
            switch (GPTModelHelper.getCurrentChatModel()) {
            case .gpt3turbo:
                return "TURBO"
            case .gpt4:
                return "PRO"
            }
        }
    }
    
    static var modelName: String {
        get {
            switch (GPTModelHelper.getCurrentChatModel()) {
            case .gpt3turbo:
                return "GPT-3"
            case .gpt4:
                return "GPT-4"
            }
        }
    }
    
}
