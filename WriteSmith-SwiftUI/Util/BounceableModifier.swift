//
//  Bounceable.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/25/23.
//

import Foundation
import SwiftUI

struct BounceableModifier: ViewModifier {
    
    @State var isDisabled: Bool
    
    
    @State private var isPressed: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .opacity(isPressed ? 0.8 : 1.0)
            .onPressReleaseGesture(onPress: {
                // Ensure not disabled, otherwise return
                guard !isDisabled else {
                    return
                }
                
                // Ensure not pressed, otherwise return
                guard !isPressed else {
                    return
                }
                
//                // Do light haptic
//                HapticHelper.doLightHaptic()
                
                // Set isPressed to true with animation
                withAnimation {
                    isPressed = true
                }
            }, onRelease: {
                // Ensure pressed, otherwise return
                guard isPressed else {
                    return
                }
                
                // Set isPressed to false with animation
                withAnimation {
                    isPressed = false
                }
            }, content: content)
    }
    
}

extension View {
    
    func bounceable(disabled: Bool = false) -> some View {
        modifier(BounceableModifier(isDisabled: disabled))
    }
    
}
