//
//  HapticHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/29/23.
//

import Foundation
import UIKit

class HapticHelper: Any {
    
    static var hapticsDisabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.UserDefaults.hapticsDisabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.hapticsDisabled)
        }
    }
    
    static func doLightHaptic() {
        guard !hapticsDisabled else {
            return
        }
        
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        
        printHaptic("LIGHT HAPTIC")
    }
    
    static func doMediumHaptic() {
        guard !hapticsDisabled else {
            return
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        printHaptic("MEDIUM HAPTIC")
    }
    
    static func doSuccessHaptic() {
        guard !hapticsDisabled else {
            return
        }
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        printHaptic("SUCCESS HAPTIC")
    }
    
    static func doWarningHaptic() {
        guard !hapticsDisabled else {
            return
        }
        
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        
        printHaptic("WARNING HAPTIC")
    }
    
    private static func printHaptic(_ hapticString: String) {
        print("__\n |\n |\n\(hapticString)\n |\n |\n_|_")
    }
    
}
