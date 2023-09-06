//
//  FirstChatGenerator.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/20/23.
//

import Foundation

class FirstChatGenerator {
    
    private static let firstChat: [String] = [
        "How may I help?",
        "How can I help you?",
        "Anything I can help you with?",
        "How may I help?",
        "Here's a tip... I work better with more detail. A sentence or two works, but you can give me paragraphs or full essays. Try it out!",
        "I'm pretty original, but use what I write as inpsiration.",
        "Hey!",
        "Hello, how can I help?",
        "Hi there, how can I help?",
        "Hello!",
        "Beep Boop",
        "How are you feeling?",
        "How are you today?",
        "Are you doing well?",
        "I'm great at writing essays!",
        "I'm great at writing poems!",
        "I'm great at writing lyrics!",
        "How are you doing today?",
    ]
    
    static func getRandomFirstChat() -> String {
        return firstChat[Int.random(in: 0..<firstChat.count)]
    }
    
}
