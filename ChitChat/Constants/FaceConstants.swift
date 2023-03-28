//
//  FaceConstants.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/17/23.
//

import Foundation

struct FaceConstants {
    enum WordType {
        case neutral
        case what
        case mask
        case nomouth
        case dead
        case curious
        case mad
    }
    
    static let orderedWordTypes: [WordType] = [
        .neutral,
        .what,
        .mask,
        .nomouth,
        .dead,
        .curious,
        .mad
    ]
    
    static let allWords: [WordType: [String]] = [
        .neutral: neutralWords,
        .what: whatWords,
        .mask: maskWords,
        .nomouth: nomouthWords,
        .dead: deadWords,
        .curious: curiousWords,
        .mad: madWords
    ]
    
    static let allFaceImageNames: [WordType: String] = [
        .neutral: "neutral",
        .what: "what",
        .mask: "mask",
        .nomouth: "nomouth",
        .dead: "dead",
        .curious: "curious",
        .mad: "mad"
    ]
    
    static let curiousWords = [
        "curious",
        "what"
    ]
    
    
    static let deadWords = [
        "lmao",
        "so funny"
    ]
    
    static let madWords = [
        "grr",
        "mad",
        "angry"
    ]
    
    static let maskWords = [
        "mask",
        "covid"
    ]
    
    static let neutralWords = [
        "npc"
    ]
    
    static let nomouthWords = [
        "no mouth",
        "stinky",
        "gross",
        "shh"
    ]
    
    static let whatWords = [
        "reeee"
    ]
}
