//
//  HapticHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/29/23.
//

import Foundation

class HapticHelper: Any {
    
    static func doLightHaptic() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    static func doMediumHaptic() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    static func doSuccessHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func doWarningHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
}
