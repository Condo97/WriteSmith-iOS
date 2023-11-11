//
//  HapticHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/29/23.
//

import Foundation

class HapticHelper: Any {
    
    static func doLightHaptic() {
//        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        printHaptic("LIGHT HAPTIC")
    }
    
    static func doMediumHaptic() {
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        printHaptic("MEDIUM HAPTIC")
    }
    
    static func doSuccessHaptic() {
//        UINotificationFeedbackGenerator().notificationOccurred(.success)
        printHaptic("SUCCESS HAPTIC")
    }
    
    static func doWarningHaptic() {
//        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        printHaptic("WARNING HAPTIC")
    }
    
    private static func printHaptic(_ hapticString: String) {
        print("__\n |\n |\n\(hapticString)\n |\n |\n_|_")
    }
    
}
