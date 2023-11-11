//
//  ButtonStateModifier.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/25/23.
//

import Foundation
import SwiftUI

struct OnPressReleaseGestureModifier: ViewModifier {
    
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(DragGesture(minimumDistance: 0.0)
                .onChanged({ dragValue in
                    onPress()
                })
                .onEnded({ dragValue in
                    onRelease()
                })
            )
    }
    
}

extension View {
    
    public func onPressReleaseGesture<C>(onPress: @escaping ()->Void, onRelease: @escaping ()->Void, content: C) -> some View {
        modifier(OnPressReleaseGestureModifier(onPress: onPress, onRelease: onRelease))
    }
    
}
