//
//  Typewriter.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 8/7/23.
//

import Foundation

class Typewriter {
    
    private var toTypeString: String
    var typingString: String
    
    private var delay: Double
    private var typingUpdateLetterCount: Int
    
    private var prevCharacter: Character?
    
    init(toTypeString: String, delay: Double, typingUpdateLetterCount: Int) {
        self.toTypeString = String(toTypeString.reversed()) // Reverse it so we can popLast for O(1)
        self.delay = delay
        self.typingUpdateLetterCount = typingUpdateLetterCount
        
        typingString = ""
    }
    
    func next() async -> String? {
        do {
            try await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
        } catch {
            // TODO: Handle error
            print("Could not sleep in next in Typewriter... \(error)")
        }
        
        // The for loop is to type multiple letters at once
        for i in 0..<typingUpdateLetterCount {
            // Unwrap typingStringLastCharacter or return nil to show it is finished
            guard let typingStringLastCharacter = toTypeString.popLast() else {
                return nil
            }
            
            typingString.append(typingStringLastCharacter)
        }
        
        return typingString
    }
    
    
    
}
