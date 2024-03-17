//
//  ImageGenerationLimiter.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/14/24.
//

import Foundation

class ImageGenerationLimiter {
    
    private static let maxFreeImages = 3
    private static let maxPremiumImages = -1 // -1 is infinite
    
    private static let userDefaultsTotalImagesGeneratedKey = "totalImagesGenerated_iuqweiqowieu323"
    
    private static var totalImagesGenerated: Int {
        get {
            UserDefaults.standard.integer(forKey: userDefaultsTotalImagesGeneratedKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userDefaultsTotalImagesGeneratedKey)
        }
    }
    
    
    static func increment() {
        totalImagesGenerated += 1
    }
    
    static func get() -> Int {
        totalImagesGenerated
    }
    
    static func canGenerateImage(isPremium: Bool) -> Bool {
        if isPremium {
            if maxPremiumImages == -1 {
                return true
            }
            
            return totalImagesGenerated < maxPremiumImages
        } else {
            if maxFreeImages == -1 {
                return true
            }
            
            return totalImagesGenerated < maxFreeImages
        }
    }
    
    
}
