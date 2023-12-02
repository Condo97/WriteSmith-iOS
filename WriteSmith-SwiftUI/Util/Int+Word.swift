//
//  Int+Word.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/30/23.
//

import Foundation

extension Int {
    
    var word: String {
        switch self {
        case 0: return "zero"
        case 1: return "one"
        case 2: return "two"
        case 3: return "three"
        case 4: return "four"
        case 5: return "five"
        case 6: return "six"
        case 7: return "seven"
        case 8: return "eight"
        case 9: return "nine"
        case 10: return "ten"
        case 11: return "eleven"
        case 12: return "twelve"
        case 13: return "thirteen"
        case 14: return "fourteen"
        case 15: return "fifteen"
        case 16: return "sixteen"
        case 17: return "seventeen"
        case 18: return "eighteen"
        case 19: return "nineteen"
        case 20...29: return "twenty" + (self > 20 ? "-" + (self % 10).word : "")
        case 30...39: return "thirty" + (self > 30 ? "-" + (self % 10).word : "")
        case 40...49: return "forty" + (self > 40 ? "-" + (self % 10).word : "")
        case 50...59: return "fifty" + (self > 50 ? "-" + (self % 10).word : "")
        case 60...69: return "sixty" + (self > 60 ? "-" + (self % 10).word : "")
        case 70...79: return "seventy" + (self > 70 ? "-" + (self % 10).word : "")
        case 80...89: return "eighty" + (self > 80 ? "-" + (self % 10).word : "")
        case 90...99: return "ninety" + (self > 90 ? "-" + (self % 10).word : "")
        case 100: return "one hundred"
        default: return "\(self)"
        }
    }
    
}
